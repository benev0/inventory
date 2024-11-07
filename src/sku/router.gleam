import gleam/dynamic.{field, int, string}
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/json
import gleam/otp/actor
import gleam/string_builder
import mist
import sku/template/home as home_template
import sku/template/message as message_template
import sku/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use ctx <- web.authenticate(req, ctx)
  use <- wisp.serve_static(req, under: "/", from: ctx.static_path)

  case wisp.path_segments(req) {
    [] -> home(ctx)
    ["profile"] -> profile()
    // configure me
    _ -> wisp.not_found()
  }
}

fn home(ctx: Context) {
  home_template.render_builder(
    ctx.user_id
    |> int.to_base16(),
  )
  |> wisp.html_response(200)
}

fn profile() {
  string_builder.from_string("<h1>Welcome to profile</h1>")
  |> wisp.html_response(200)
}

pub type WebSocketActorMessage {
  Broadcast(String)
}

type WSMessage {
  WSMessage(String)
}

fn handle_ws_message(state, conn, message) {
  case message {
    //   mist.Text("up") -> {
    //     io.print("up\n")
    //     let assert Ok(_) =
    //       mist.send_text_frame(
    //         conn,
    //         int.to_base16(state) |> message_template.render(),
    //       )
    //     actor.continue(state + 1)
    //   }
    //   mist.Text("down") -> {
    //     let assert Ok(_) = mist.send_text_frame(conn, int.to_base16(state))
    //     actor.continue(state - 1)
    //   }
    mist.Text(content) -> {
      let content_decoder =
        dynamic.decode1(WSMessage, field("chat_message", of: string))

      let _ = json.decode(content, content_decoder)

      let assert Ok(_) =
        mist.send_text_frame(
          conn,
          int.to_base16(state) |> message_template.render(),
        )

      actor.continue(state + 1)
    }

    mist.Text(_) | mist.Binary(_) -> {
      let assert Ok(_) = mist.send_text_frame(conn, "hello is anyone there?")
      actor.continue(state)
    }

    mist.Custom(Broadcast(text)) -> {
      let assert Ok(_) = mist.send_text_frame(conn, text)
      actor.continue(state)
    }

    mist.Closed | mist.Shutdown -> actor.Stop(process.Normal)
  }
}

// fn handle_ws_init(_conn) {
//   //"this state should be replaced later with dynamic content"
//   #(mist.Text("pong"), option.None)
// }

fn handle_ws_close(_state) {
  io.println("goodbye!")
}

pub fn create_ws(req, on_init) {
  mist.websocket(req, handle_ws_message, on_init, handle_ws_close)
}
