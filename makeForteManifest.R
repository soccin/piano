argv=commandArgs(trailing=T)

if(len(argv)!=2) {
    cat("\n usage: makeForteManifest.R strand mapping.txt\n")
    cat("    strand: yes/no/reverse\n\n")
    quit()
}

suppressPackageStartupMessages(require(tidyverse))
strand=argv[1]
mapFile=argv[2]

map=read_tsv(mapFile,col_names=F)

fmap=list()
projectNo=str_extract(map$X4[1],"/Project_([^/]+)/",group=T)

for(mi in map %>% transpose) {

    R1=fs::dir_ls(mi$X4,regex="_R1_\\d+.fastq.gz") %>% sort
    R2=fs::dir_ls(mi$X4,regex="_R2_\\d+.fastq.gz") %>% sort

    if(any(gsub("_R1_\\d+.*","",R1)!=gsub("_R2_\\d+.*","",R2))) {
        cat("\n\nR1,R2 mismatch\n")
    }

    SID=paste0("p",projectNo,".",gsub("^s_","-",mi$X2))

    fmap[[len(fmap)+1]]=tibble(sample=SID,strand=strand,fastq_1=R1,fastq_2=R2)

}

fmap=bind_rows(fmap)

write_csv(fmap,gsub("_sample_mapping.txt","_forte_input.csv",basename(mapFile)))
