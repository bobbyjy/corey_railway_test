library(tidyverse)
library(rvest)
library(jsonlite)
library(DBI)
library(RPostgres)

get_new_resp <- function() {
  url <- "https://www.boredapi.com/api/activity"
  response <- read_html(url) %>% html_text %>% fromJSON %>% as.data.frame
  response <- response[c("activity","type","participants","price")]
  return(response)
}


con <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("PGHOST"),
  dbname = Sys.getenv("PGDATABASE"),
  user = Sys.getenv("PGUSER"),
  password = Sys.getenv("PGPASSWORD"),
  port = Sys.getenv("PGPORT")
)

# con <- dbConnect(RPostgres::Postgres(),
#                  dbname= 'analysis',
#                  host= 'localhost',
#                  port= 5432,
#                  user= 'postgres',
#                  password ='Lgrch845lngy$')

dbExecute(con,
          "CREATE TABLE IF NOT EXISTS activities (
            id SERIAL PRIMARY KEY,
            activity TEXT,
            type TEXT,
            participants INT,
            price NUMERIC(5,2),
            time TIMESTAMPTZ
            )")

while (TRUE) {
  resp <- get_new_resp() %>% unname
  dbExecute(con,
            "INSERT INTO activities (activity, type, participants, price, time)
            VALUES ($1,$2,$3,$4, current_timestamp)",
            params = resp
            )
  print("Added")
  Sys.sleep(60) #1 min sleep time
}

