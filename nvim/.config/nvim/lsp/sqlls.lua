return {
  cmd = {'sql-language-server', 'up', '--method', 'stdio'},
  filetypes = { "sql" },
  root_markers = {
    ".git",
    "dbconfig.json",
  },
  settings = {
    sqlLanguageServer = {
      connections = {
        {
          name = "PostgreSQL-Misc",
          adapter = "postgresql",
          host = "localhost",     -- Change if your PostgreSQL is on a different host
          port = 5432,            -- Default PostgreSQL port (change if needed)
          database = "misc",      -- Your database name
          user = "danielh",       -- Your PostgreSQL username
          password = "sobersuck1"
        }
      }
    }
  },
}
