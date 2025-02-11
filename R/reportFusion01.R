eventSummary<-function(dat) {
    summarize(dat,
        NSamples=n(),
        Samples=paste(sample,collapse=","),
        Tools=paste(unique(Tools),collapse=";"),
        max_split=max(max_split_cnt),
        max_span=max(max_span_cnt),
        maxCallers=max(nCallers)
    ) |> ungroup()
}

junctionTbl<-function(dat) {
    dat %>%
        left_join(fusionTagNameTbl) %>%
        arrange(desc(NSamples),desc(maxCallers)) %>%
        filter(NSamples>1) %>%
        left_join(oncokb) %>%
        select(-matches("HIGHEST")) %>%
        select(FusionJunction=FusionTag,Fusion,everything()) %>%
        select(-Samples,Samples)
}

SDIR=Sys.getenv("SDIR")

source(file.path(SDIR,"R/read_cff.R"))

#
#
if(exists(".INCLUDE") && .INCLUDE) {halt(".INCLUDE")}
#
#
.INCLUDE=T

require(tidyverse)

projNo=grep("Proj_",strsplit(getwd(),"/")[[1]],value=T)

INDIR="out"
cffFiles=fs::dir_ls(INDIR,recur=3,regex="analysis/.*/metafusion") %>%
    fs::dir_ls(regex="\\.final\\.cff$")
cff0=map(cffFiles,read_cff)

oncoKbAnnotatedFile=cc(projNo,"_UniqueFusions.oncokb.tsv")

if(file.exists(oncoKbAnnotatedFile)) {

    oncokb=read_tsv(oncoKbAnnotatedFile,col_types=cols(.default="c")) %>%
        filter(GENE_IN_ONCOKB=="True") %>%
        select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>%
        arrange_at(vars(matches("HIGH"))) %>%
        distinct %>%
        mutate(Fusion=gsub("-","::",Fusion))

} else {


    cat("\n\n")
    cat("Run oncokb-annotator/FusionAnnotator.py (in CMD.oncoKb)\n\n")
    quit()

}

cff1=map(cff0,clean_cff) %>% bind_rows

log1pBreaks=c(0,(1:9),(1:9)*10,(1:9)*100)
dg=cff1 %>% select(matches("max_|Call")) %>% gather(CountType,Count,-nCallers)

pc1=dg %>% ggplot(aes(Count,fill=CountType)) + theme_light(12) + geom_density(alpha=.2) + scale_x_continuous(trans="log1p",breaks=log1pBreaks) + theme(panel.grid.minor = element_blank()) + scale_fill_brewer(palette="Dark2")
pc2=dg %>% ggplot(aes(Count,fill=factor(nCallers))) + theme_light(12) + geom_density(alpha=.2) + scale_x_continuous(trans="log1p",breaks=log1pBreaks) + theme(panel.grid.minor = element_blank())

#x11 = function (...) grDevices::x11(...,type='cairo')

require(UpSetR)
require(grid)

calls=cff0 %>% bind_rows %>% arrange(desc(max_split_cnt)) %>% distinct(sample,FusionTag,tool,.keep_all=T) %>% select(tool,FusionTag) %>% group_split(tool)
names(calls)=map_vec(calls,~.$tool[1])
calls=map(calls,"FusionTag")

pg=UpSetR::upset(fromList(calls))
#grid.text("Unfiltered",x = 0.65, y=0.95, gp=gpar(fontsize=20))
pdf(file="qcCallerOverlap.pdf",width=10,height=5.625)
print(pg)
dev.off()

fusionTagNameTbl=cff1 %>% distinct(FusionTag,Fusion,FusionType,Fusion_effect)
fusionAnnote=cff1 %>% distinct(Fusion,FusionType,Fusion_effect)

tbl1=cff1 %>%
    select(
        Sample=sample,Fusion,Junction=FusionTag,max_split_cnt,max_span_cnt,
        FusionType,Fusion_effect,Tools,nCallers) %>%
    arrange(Sample,Fusion,Junction) %>%
    left_join(oncokb) %>%
    arrange(desc(nCallers),desc(max_split_cnt))

tbl1on=tbl1 %>% filter(!is.na( HIGHEST_LEVEL)) %>% arrange(desc(max_split_cnt))

tbl1.f1=tbl1 %>% filter(nCallers>1)


if(length(unique(tbl1$Sample))>1) {

    cat("Multiple samples found\n")
    cat("Need to implement multi-sample report\n")
    rlang::abort("Multiple samples found")

} else {

    ffile=cc(projNo,"_FusionTableV4.xlsx")
    tbl=list(HC.Events=tbl1.f1,AllEvents=tbl1)
    openxlsx::write.xlsx(tbl,ffile)
    write_csv(tbl1,cc(projNo,"_FusionTableV4__allEvents.csv"))

}

