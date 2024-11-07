import gleam/int
import gleam/option
import gleam/result
import sku/database
import sku/user
import wisp.{type Request, type Response}

pub type Context {
  Context(db: database.Connection, user_id: Int, static_path: String)
}

const uid_cookie = "uid"

pub fn authenticate(
  req: Request,
  ctx: Context,
  next: fn(Context) -> Response,
) -> Response {
  let id =
    wisp.get_cookie(req, uid_cookie, wisp.Signed)
    |> result.try(int.parse)
    |> option.from_result

  let #(id, new_user) = case id {
    option.None -> {
      wisp.log_info("Creating a new user")
      let user = user.insert_user(ctx.db)
      #(user, True)
    }
    option.Some(id) -> #(id, False)
  }

  let context = Context(..ctx, user_id: id)
  let resp = next(context)

  case new_user {
    True -> {
      let id = int.to_string(id)
      let year = 60 * 60 * 24 * 365
      wisp.set_cookie(resp, req, uid_cookie, id, wisp.Signed, year)
    }
    False -> resp
  }
}
