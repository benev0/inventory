import gleam/result
import sku/error.{type AppError}
import sqlight

pub type Connection =
  sqlight.Connection

pub fn with_connection(name: String, f: fn(sqlight.Connection) -> a) {
  use db <- sqlight.with_connection(name)
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on;", db)
  f(db)
}

/// Run some idempotent DDL to ensure we have the PostgreSQL database schema
/// that we want. This should be run when the application starts.
pub fn migrate_schema(db: sqlight.Connection) -> Result(Nil, AppError) {
  sqlight.exec(
    "
    create table if not exists users (
      id integer primary key autoincrement not null
    ) strict;",
    db,
  )
  |> result.map_error(error.SqlightError)
}
