suppressPackageStartupMessages(require(tidyverse))
args=commandArgs(trailing=T)
strand=args[1]
mapFile=args[2]

map=read_tsv(mapFile,col_names=F)

fmap=list()

for(mi in map %>% transpose) {

    R1=fs::dir_ls(mi$X4,regex="_R1_\\d+.fastq.gz") %>% sort
    R2=fs::dir_ls(mi$X4,regex="_R2_\\d+.fastq.gz") %>% sort

    if(any(gsub("_R1_\\d+.*","",R1)!=gsub("_R2_\\d+.*","",R2))) {
        cat("\n\nR1,R2 mismatch\n")
    }

    fmap[[len(fmap)+1]]=tibble(sample=mi$X2,strand=strand,fastq_1=R1,fastq_2=R2)

}

fmap=bind_rows(fmap)
write_csv(fmap,gsub("_sample_mapping.txt","_forte_input.csv",basename(mapFile)))

tumors=fmap %>% mutate(SID=as.numeric(gsub("s_CTCL","",sample))) %>% filter(SID%%2==1) %>% select(-SID)
normals=fmap %>% mutate(SID=as.numeric(gsub("s_CTCL","",sample))) %>% filter(SID%%2==0) %>% select(-SID)

write_csv(normals,gsub("_sample_mapping.txt","_normals_forte_input.csv",basename(mapFile)))
write_csv(tumors,gsub("_sample_mapping.txt","_tumors_forte_input.csv",basename(mapFile)))
