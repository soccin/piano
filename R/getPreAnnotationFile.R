SDIR=Sys.getenv("SDIR")
source(file.path(SDIR,"R/read_cff.R"))

require(tidyverse)


projNo=grep("Proj_",strsplit(getwd(),"/")[[1]],value=T)%>%tail(1)

INDIR="out"
cffFiles=fs::dir_ls(INDIR,recur=3,regex="analysis/.*/metafusion") %>%
    fs::dir_ls(regex="\\.final\\.cff$")
cff0=map(cffFiles,read_cff)

oncoKbAnnotatedFile=cc(projNo,"_UniqueFusions.tsv")

oncoTbl=cff0 %>%
    bind_rows %>%
    select(sample,FID,reann_gene5_symbol,reann_gene3_symbol) %>%
    filter(!is.na(reann_gene5_symbol)) %>%
    filter(!is.na(reann_gene3_symbol)) %>%
    filter(!grepl("-",reann_gene5_symbol)) %>%
    filter(!grepl("-",reann_gene3_symbol)) %>%
    unite(Tumor_Sample_Barcode,sample,FID,sep=",") %>%
    unite(Fusion,reann_gene5_symbol,reann_gene3_symbol,sep="-")

write_tsv(oncoTbl,oncoKbAnnotatedFile)

