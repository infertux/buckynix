# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Buckynix.Repo.insert!(%Buckynix.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Buckynix.{Repo, User, Customer}

users = [
  %{
    name: "John Doe",
    email: "john@example.net",
    password: "rubbish",
    password_confirmation: "rubbish"
  },
  %{
    name: "Bob Carrot",
    email: "bob@carrot.net",
    password: "rubbish",
    password_confirmation: "rubbish"
  },
  %{
    name: "Buck Baller",
    email: "buck@baller.xyz",
    password: "rubbish",
    password_confirmation: "rubbish"
  },
]
|> Enum.map(&User.changeset(%User{}, &1))
|> Enum.map(&Repo.insert!(&1))

customers = [
  %{
    name: "John Doe",
    email: "john@example.net",
    tags: ~w(test),
    # password: "12345678"
  },
  %{
    name: "Bob Carrot",
    email: "bob@carrot.net",
    tags: ~w(crazy carrot test)
  },
  %{
    name: "Buck Baller",
    email: "buck@baller.xyz",
    tags: [],
  },
]
|> Enum.map(&Customer.changeset(%Customer{}, &1))
|> Enum.map(&Repo.insert!(&1))

accounts = customers
|> Enum.map(&Ecto.build_assoc(&1, :account, %{currency: "EUR"}))
|> Enum.map(&Repo.insert!(&1))

for i <- 1..Enum.random(1..3) do
  transactions = accounts
  |> Enum.map(&Ecto.build_assoc(&1, :transaction, %{
    amount: Enum.random(1..1000), description: "Test tx", value_date: Ecto.DateTime.utc
  }))
  |> Enum.map(&Repo.insert!(&1))
end
