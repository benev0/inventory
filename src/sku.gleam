import gleam/bytes_builder
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/result
import mist.{type Connection, type ResponseData}

pub fn main() {
  let not_found =
    response.new(404)
    |> response.set_body(
      mist.Bytes(bytes_builder.from_string("404 page not found")),
    )

  // site
  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        [] -> serve_page(req)
        _ -> not_found
      }
    }
    |> mist.new
    |> mist.port(4200)
    |> mist.start_http
  process.sleep_forever()
}

fn serve_page(request: Request(Connection)) -> Response(ResponseData) {
  mist.read_body(request, 1024 * 1024 * 10)
  |> result.map(fn(_req) {
    response.new(200)
    |> response.set_body(mist.Bytes(bytes_builder.from_string("Hello World!")))
  })
  |> result.lazy_unwrap(fn() {
    response.new(400)
    |> response.set_body(mist.Bytes(bytes_builder.new()))
  })
}
