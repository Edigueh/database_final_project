import unittest
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from types import SimpleNamespace
from unittest.mock import patch

from app import QUERIES, display_results, execute_query, main


class FakeCursor:
    description = [SimpleNamespace(name="valor")]

    def __init__(self, rows=None):
        self.calls = []
        self.rows = [("resultado",)] if rows is None else rows

    def execute(self, *args):
        self.calls.append(args)

    def fetchall(self):
        return self.rows


class AppTests(unittest.TestCase):
    def test_query_list_and_runtime_parameters(self):
        self.assertEqual(len(QUERIES), 10)
        self.assertIn("%s", QUERIES[5].sql)
        self.assertIn("%s", QUERIES[9].sql)
        self.assertEqual(sum("%s" in query.sql for query in QUERIES), 2)
        self.assertIsNotNone(QUERIES[5].parameter_prompt)
        self.assertIsNotNone(QUERIES[9].parameter_prompt)

    def test_execute_query_binds_value_separately(self):
        cursor = FakeCursor()
        sql = "SELECT %s AS valor"
        params = ("texto'; SELECT 1; --",)

        columns, rows = execute_query(cursor, sql, params)

        self.assertEqual(cursor.calls, [(sql, params)])
        self.assertEqual(columns, ["valor"])
        self.assertEqual(rows, [("resultado",)])

    def test_execute_query_without_parameters(self):
        cursor = FakeCursor()

        execute_query(cursor, "SELECT 1")

        self.assertEqual(cursor.calls, [("SELECT 1",)])

    def test_empty_results_are_reported(self):
        output = StringIO()

        with redirect_stdout(output):
            display_results(["valor"], [])

        self.assertEqual(output.getvalue(), "Sem resultados.\n")

    def test_missing_database_url_is_reported(self):
        error_output = StringIO()

        with patch.dict("os.environ", {"DATABASE_URL": ""}), redirect_stderr(error_output):
            result = main()

        self.assertEqual(result, 1)
        self.assertIn("Defina DATABASE_URL", error_output.getvalue())


if __name__ == "__main__":
    unittest.main()
