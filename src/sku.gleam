import gleam/erlang/os
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/io
import gleam/option
import gleam/result
import mist.{type ResponseData}
import sku/database
import sku/router
import sku/web.{Context}
import wisp
import wisp/wisp_mist

const db_name = "todomvc.sqlite3"

pub fn main() {
  let selector = process.new_selector()
  let state = 0

  wisp.configure_logger()

  let port = load_port()
  let secret_key_base = load_application_secret()
  let assert Ok(priv) = wisp.priv_directory("sku")
  let assert Ok(_) = database.with_connection(db_name, database.migrate_schema)

  let handle_request = fn(req) {
    use db <- database.with_connection(db_name)
    let ctx = Context(user_id: 0, db: db, static_path: priv <> "/static")
    router.handle_request(req, ctx)
  }

  let assert Ok(_) =
    fn(req: Request(_)) -> Response(ResponseData) {
      case req.path {
        "/ws" ->
          router.create_ws(req, fn(_conn) {
            io.print("connecting\n")
            #(state, option.Some(selector))
          })
        _ -> wisp_mist.handler(handle_request, secret_key_base)(req)
      }
    }
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}

// to do: panic if no secret
fn load_application_secret() -> String {
  os.get_env("APPLICATION_SECRET")
  |> result.unwrap("100")
  // |> result.unwrap(wisp.random_string(64))
}

fn load_port() -> Int {
  os.get_env("PORT")
  |> result.then(int.parse)
  |> result.unwrap(4200)
}
