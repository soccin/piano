argv=commandArgs(trailing=T)
if(len(argv)<1) {
  cat("
   usage: fastqDirToBICMap.R fastqDir1 [fastqDir2 ...]

")
  quit()
}

require(tidyverse)

map0=tibble(X1="_1",X2="",X3="",X4=argv,X5="PE") %>%
  mutate(X2=basename(X4)%>%gsub("_IGO_.*","",.)%>%gsub("^Sample_","",.)) %>%
  mutate(X3=basename(dirname(X4)))

projNo=getwd() %>%
  strsplit(.,"/") %>%
  unlist %>%
  grep("Proj_",.,value=T) %>%
  tail(1) %>%
  gsub("Proj_","",.)

map0 %>%
  write_tsv(cc(projNo,"sample_mapping.txt"),col_names=F)
