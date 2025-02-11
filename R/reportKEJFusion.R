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

pdf(file="qcFusionCounts01.pdf",width=10,height=5.625)
print(pc1)
print(pc1 + facet_wrap(~CountType,ncol=1))
print(pc1 + facet_wrap(~nCallers,ncol=1))
print(pc2 + facet_wrap(~CountType,ncol=1))
dev.off()

require(UpSetR)
require(grid)

pdf(file="qcCallerOverlap.pdf",width=10,height=5.625)

calls=cff0 %>% bind_rows %>% arrange(desc(max_split_cnt)) %>% distinct(sample,FusionTag,tool,.keep_all=T) %>% select(tool,FusionTag) %>% group_split(tool)
names(calls)=map_vec(calls,~.$tool[1])
calls=map(calls,"FusionTag")

UpSetR::upset(fromList(calls))
grid.text("Unfiltered",x = 0.65, y=0.95, gp=gpar(fontsize=20))

# calls=cff0 %>% bind_rows %>% filter(max_split_cnt>3 & max_span_cnt>10) %>% arrange(desc(max_split_cnt)) %>% distinct(sample,FusionTag,tool,.keep_all=T) %>% select(tool,FusionTag) %>% group_split(tool)
# names(calls)=map_vec(calls,~.$tool[1])
# calls=map(calls,"FusionTag")

#UpSetR::upset(fromList(calls))
#grid.text("Split>3 && Span>10",x = 0.65, y=0.95, gp=gpar(fontsize=20))

dev.off()

fusionTagNameTbl=cff1 %>% distinct(FusionTag,Fusion,FusionType,Fusion_effect)
fusionAnnote=cff1 %>% distinct(Fusion,FusionType,Fusion_effect)

qcTbl1=cff1 %>%
    distinct(sample,FusionTag,.keep_all=T) %>%
    filter(Fusion=="SMG1::NPIPB5") %>%
    filter(sample=="s_CTCL18") %>%
    select(
        sample,Fusion,gene5_chr,gene5_breakpoint,gene5_strand,
        gene3_chr,gene3_breakpoint,gene3_strand,
        max_split_cnt,max_span_cnt,
        Tools,nCallers,FusionType,Fusion_effect
    )

openxlsx::write.xlsx(qcTbl1,"qcTbl_MultiFusions_01.xlsx")

#halt("Break-128")

tbl1=cff1 %>%
    select(
        Sample=sample,Fusion,Junction=FusionTag,max_split_cnt,max_span_cnt,
        FusionType,Fusion_effect,Tools,nCallers) %>%
    arrange(Sample,Fusion,Junction) %>%
    left_join(oncokb) %>%
    arrange(desc(nCallers),desc(max_split_cnt))

tbl1on=tbl1 %>% filter(!is.na( HIGHEST_LEVEL)) %>% arrange(desc(max_split_cnt))

tbl2=cff1 %>%
    arrange(desc(max_split_cnt)) %>%
    rename(Sample=sample) %>%
    distinct(Sample,Fusion,.keep_all=T) %>%
    arrange(Sample,Fusion) %>%
    select(
        Sample,Fusion,Junction=FusionTag,max_split_cnt,max_span_cnt,
        FusionType,Fusion_effect,Tools,nCallers) %>%
    left_join(oncokb) %>%
    arrange(desc(nCallers),desc(max_split_cnt))

ffile=cc(projNo,"_FusionTableV3.xlsx")
tbl=list(allEvents=tbl1,uniqSampleFusion=tbl2)
openxlsx::write.xlsx(tbl,ffile)
write_csv(tbl1,cc(projNo,"_FusionTableV3__allEvents.csv"))

topFusions3=tbl1 %>%
    filter(nCallers>2) %>%
    filter(FusionType!="SameGene" & FusionType!="ReadThrough") %>%
    distinct(Fusion,Sample) %>%
    count(Fusion) %>%
    arrange(desc(n))

topFusions2=tbl1 %>%
    filter(nCallers>1) %>%
    filter(FusionType!="SameGene" & FusionType!="ReadThrough") %>%
    distinct(Fusion,Sample) %>%
    count(Fusion) %>%
    arrange(desc(n))

topGenes2=cff1 %>%
    filter(nCallers>1) %>%
    select(Fusion,sample,reann_gene5_symbol,reann_gene3_symbol,FusionType) %>%
    filter(FusionType!="SameGene" & FusionType!="ReadThrough") %>%
    select(-FusionType,-Fusion) %>%
    gather(End,Gene,reann_gene5_symbol,reann_gene3_symbol) %>%
    distinct(sample,Gene) %>%
    count(Gene) %>%
    arrange(desc(n))

ffile=cc(projNo,"_TopTableV1.xlsx")
ttbl=list(topFusions3Calls=topFusions3,topFusions2Calls=topFusions2,topGenes=topGenes2)
openxlsx::write.xlsx(ttbl,ffile)

# fusions=tbl1 %>% separate(Fusion,c("Gene5p","Gene3p"),sep="::",remove=F)

# genes=scan("genesToLookAt","")

# testList3=fusions %>% filter(Gene5p %in% genes | Gene3p %in% genes) %>% filter(nCallers>2)
# testList2=fusions %>% filter(Gene5p %in% genes | Gene3p %in% genes) %>% filter(nCallers>1)

# write_csv(testList3,"test3FusionsForIntegrate.csv")
# write_csv(testList2,"test2FusionsForIntegrate.csv")

# testList2 %>% distinct(Sample) %>% pull %>% write("samplesToTestPass1")

