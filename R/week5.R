# R Studio API Code
library(rstudioapi)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) 

# Data Import
library(tidyverse)
Adata_tbl <- read_delim("../Data/week5/Aparticipants.dat",delim=c("-"),col_names=c("casenum","parnum","stimver","datadate","qs")) 
Anotes_tbl <- read_csv("../Data/week5/Anotes.csv")
Bdata_tbl <- read_tsv("../Data/week5/Bparticipants.dat",col_names=c("casenum","parnum","stimver","datadate",paste0("q",1:10)))
Bnotes_tbl <- read_tsv("../Data/week5/Bnotes.txt")

# Data Cleaning
Adata_tbl <- Adata_tbl %>% 
  separate(qs,paste0("q",1:5),sep=" - ") %>%
  mutate_at(vars(q1:q5),as.numeric) %>%
  mutate(datadate=as.POSIXct(datadate,format="%b %d %Y, %H:%M:%S"))

Aaggr_tbl <- Adata_tbl %>% select(parnum,q1:q5) %>%
  group_by(parnum) %>% 
  summarise_at(vars(q1:q5),mean)
Baggr_tbl <- Bdata_tbl %>% select(parnum,q1:q5) %>%
  group_by(parnum) %>% 
  summarise_at(vars(q1:q5),mean)
Aaggr_tbl <- Aaggr_tbl %>% inner_join(Anotes_tbl,"parnum")
Baggr_tbl <- Baggr_tbl %>% inner_join(Bnotes_tbl,"parnum")
Aaggr_tbl %>% 
  bind_rows(Baggr_tbl,.id="source") %>%
  filter(is.na(notes)) %>%
  count(source)
