library(pecanapi)
library(tidyverse)

con <- DBI::dbConnect(
  RPostgres::Postgres(),
  user = "bety",
  password = "bety",
  host = "localhost",
  port = 7990
)

model_id <- get_model_id(con, "SIPNET", "136")
site_id <- search_sites(con, "niwot ridge forest")[["id"]]
workflow <- insert_new_workflow(
  con, site_id, model_id,
  start_date = "2004-01-01",
  end_date = "2004-12-31"
)

workflow_id <- workflow[["id"]]

settings <- list() %>%
  add_workflow(workflow) %>%
  add_database() %>%
  add_rabbitmq(con = con) %>%
  add_pft("temperate.deciduous") %>%
  modifyList(list(
    meta.analysis = list(iter = 3000, random.effects = FALSE),
    run = list(
      inputs = list(met = list(source = "CRUNCEP",
                               output = "SIPNET",
                               method = "ncss"))
    )
  ))

submit_workflow(settings)
readLines(run_url(workflow_id, "workflow.Rout"))
