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

source("read_cff.R")

#
#
if(exists(".INCLUDE") && .INCLUDE) {halt(".INCLUDE")}
#
#
.INCLUDE=T

require(tidyverse)

projNo=grep("Proj_",strsplit(getwd(),"/")[[1]],value=T)

INDIR="output/analysis"
cffFiles=fs::dir_ls(INDIR) %>%
    fs::dir_ls(regex="metafusion") %>%
    fs::dir_ls(regex="\\.final\\.cff")

cff0=map(cffFiles,read_cff)

if(file.exists(cc(projNo,"UniqueFusions.oncokb.tsv"))) {
    # oncokb=read_tsv(cc(projNo,"UniqueFusions.oncokb.tsv"),col_types=cols(.default="c")) %>%
    #     separate(Tumor_Sample_Barcode,c("sample","FID"),sep=",") %>%
    #     separate(Fusion,c("reann_gene5_symbol","reann_gene3_symbol"),sep="-")

    oncokb=read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv",col_types=cols(.default="c")) %>%
        filter(GENE_IN_ONCOKB=="True") %>%
        select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>%
        arrange_at(vars(matches("HIGH"))) %>%
        distinct %>%
        mutate(Fusion=gsub("-","::",Fusion))

} else {

    oncoTbl=cff0 %>%
        bind_rows %>%
        select(sample,FID,reann_gene5_symbol,reann_gene3_symbol) %>%
        filter(!is.na(reann_gene5_symbol)) %>%
        filter(!is.na(reann_gene3_symbol)) %>%
        filter(!grepl("-",reann_gene5_symbol)) %>%
        filter(!grepl("-",reann_gene3_symbol)) %>%
        unite(Tumor_Sample_Barcode,sample,FID,sep=",") %>%
        unite(Fusion,reann_gene5_symbol,reann_gene3_symbol,sep="-")

    write_tsv(oncoTbl,cc(projNo,"UniqueFusions.tsv"))

    cat("\n\n")
    cat("Run oncokb-annotator/FusionAnnotator.py (in CMD.oncoKb)\n\n")
    quit()

}

cff1=map(cff0,clean_cff) %>% bind_rows

log1pBreaks=c(0,(1:9),(1:9)*10,(1:9)*100)
dg=cff1 %>% select(matches("max_|Call")) %>% gather(CountType,Count,-nCallers)

pc1=dg %>% ggplot(aes(Count,fill=CountType)) + theme_light(12) + geom_density(alpha=.2) + scale_x_continuous(trans="log1p",breaks=log1pBreaks) + theme(panel.grid.minor = element_blank()) + scale_fill_brewer(palette="Dark2")
pc2=dg %>% ggplot(aes(Count,fill=factor(nCallers))) + theme_light(12) + geom_density(alpha=.2) + scale_x_continuous(trans="log1p",breaks=log1pBreaks) + theme(panel.grid.minor = element_blank())

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
    left_join(oncokb)

tbl1on=tbl1 %>% filter(!is.na( HIGHEST_LEVEL)) %>% arrange(desc(max_split_cnt))

tbl2=cff1 %>%
    arrange(desc(max_split_cnt)) %>%
    rename(Sample=sample) %>%
    distinct(Sample,Fusion,.keep_all=T) %>%
    arrange(Sample,Fusion) %>%
    select(
        Sample,Fusion,Junction=FusionTag,max_split_cnt,max_span_cnt,
        FusionType,Fusion_effect,Tools,nCallers) %>%
    left_join(oncokb)

ffile="Proj_14879_B__FusionTableV3.xlsx"
tbl=list(allEvents=tbl1,uniqSampleFusion=tbl2)
openxlsx::write.xlsx(tbl,ffile)
write_csv(tbl1,"Proj_14879_B__FusionTableV3__allEvents.csv")

topFusions=tbl1 %>% filter(FusionType!="SameGene" & FusionType!="ReadThrough") %>% distinct(Fusion,Sample) %>% count(Fusion) %>% arrange(desc(n))

topGenes=cff1 %>%
    select(Fusion,sample,reann_gene5_symbol,reann_gene3_symbol,FusionType) %>%
    filter(FusionType!="SameGene" & FusionType!="ReadThrough") %>%
    select(-FusionType,-Fusion) %>%
    gather(End,Gene,reann_gene5_symbol,reann_gene3_symbol) %>%
    distinct(sample,Gene) %>%
    count(Gene) %>%
    arrange(desc(n))

tblE=cff1 %>%
    select(Fusion,sample,reann_gene5_symbol,reann_gene3_symbol,FusionType,matches("exon|Exon"),matches("max")) %>%
    filter(FusionType!="SameGene" & FusionType!="ReadThrough" & Fusion!="TIMM23::PARGP1") %>%
    select(-FusionType) %>%
    unite(exon5,reann_gene5_symbol,closest_exon5,sep="__") %>%
    unite(exon3,reann_gene3_symbol,closest_exon3,sep="__")  %>%
    left_join(topFusions) %>%
    arrange(desc(n))


ffile="Proj_14879_B__TopTableV1.xlsx"
ttbl=list(topFusions=topFusions,topGenes=topGenes,exonsUsed=tblE)
openxlsx::write.xlsx(ttbl,ffile)

fusions=tbl1 %>% separate(Fusion,c("Gene5p","Gene3p"),sep="::",remove=F)

genes=scan("genesToLookAt","")

testList3=fusions %>% filter(Gene5p %in% genes | Gene3p %in% genes) %>% filter(nCallers>2)
testList2=fusions %>% filter(Gene5p %in% genes | Gene3p %in% genes) %>% filter(nCallers>1)

write_csv(testList3,"test3FusionsForIntegrate.csv")
write_csv(testList2,"test2FusionsForIntegrate.csv")

testList2 %>% distinct(Sample) %>% pull %>% write("samplesToTestPass1")

