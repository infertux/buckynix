defmodule Buckynix.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :currency, :string, null: false
      add :balance, :integer, null: false, default: 0

      timestamps()
    end

    create index(:accounts, [:user_id])

    execute "
      CREATE TRIGGER accounts_delete
      BEFORE DELETE ON accounts
      FOR EACH ROW EXECUTE PROCEDURE never_delete();
    "

    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :amount, :integer, null: false
      add :description, :string, null: false
      add :value_date, :datetime, null: false
      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:transactions, [:account_id])

    execute "
      CREATE TRIGGER transactions_delete
      BEFORE DELETE ON transactions
      FOR EACH ROW EXECUTE PROCEDURE never_delete();
    " # FIXME: never_update too?

    # XXX: otherwise the balance calculated below will be incorrect as it will include future transactions
    create constraint(:transactions, :value_date_must_be_past, check: "value_date <= NOW()")

    execute "
      CREATE OR REPLACE FUNCTION accounts_balance_update() RETURNS trigger AS $$
      BEGIN
        UPDATE accounts SET balance = (
          SELECT SUM(amount) FROM transactions WHERE account_id = NEW.account_id
        )
        WHERE id = NEW.account_id;

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    "

    execute "
      CREATE TRIGGER accounts_balance_update
      AFTER INSERT OR UPDATE ON transactions
      FOR EACH ROW EXECUTE PROCEDURE accounts_balance_update();
    "
  end
end
