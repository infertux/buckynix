defmodule Buckynix.DeliveryControllerTest do
  use Buckynix.ConnCase

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, delivery_path(conn, :index)
    assert html_response(conn, 200)
  end
end
