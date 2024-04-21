source("reportMetaFusion.R")
pon_Breakpoints
cffN %>% group_by(FusionTag) %>% ungroup
cffN %>% group_by(FusionTag) %>% eventSummary %>% ungroup
pon_Breakpoints
pon_Breakpoints==cffN %>% group_by(FusionTag) %>% eventSummary %>% ungroup
all(pon_Breakpoints==cffN %>% group_by(FusionTag) %>% eventSummary %>% ungroup)
exists(".INCLUDE")
source("makeForteManifest.R")
source("makeForteManifest.R")
source("makeForteManifest.R")
source("reportMetaFusion.R")
source("reportMetaFusion.R")
exists(".INCLUDE")
source("reportMetaFusion.R")
source("reportMetaFusion.R")
source("reportMetaFusion.R")
source("reportMetaFusion.R")
source("reportMetaFusion.R")
.INCLUDE=F
source("reportMetaFusion.R")
source("reportMetaFusion.R")
all(pon_Breakpoints==cffN %>% group_by(FusionTag) %>% eventSummary)
cffN %>% group_by(FusionTag) %>% eventSummary
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag))
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% filter(nCallers>1)
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% filter(nCallers>1) %>% group_by(Fusion) %>% eventSummary()
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% filter(nCallers>1) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples))
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% filter(nCallers>1) %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples))
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples))
cffN %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples))
cffN %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(NSamples>2)
cffN %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(NSamples>2) %>% pull(Fusion)
nFusions=cffN %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(NSamples>2) %>% pull(Fusion)
normalFusions=cffN %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(NSamples>2) %>% pull(Fusion)
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(Fusion %in% nFusions)
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(!(Fusion %in% nFusions))
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(!(Fusion %in% nFusions)) %>% filter(NSamples>1)
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% filter(nCallers>1) %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(!(Fusion %in% nFusions)) %>% filter(NSamples>1)
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% filter(nCallers>1) %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(NSamples>1)
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv")
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv") %>% filter(GENE_IN_ONCOKB)
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv") %>% filter(GENE_IN_ONCOKB) %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH"))
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv") %>% filter(GENE_IN_ONCOKB) %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>% arrange_at(vars(matches("HIGH"))
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv") %>% filter(GENE_IN_ONCOKB) %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>% arrange_at(vars(matches("HIGH")))
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv") %>% filter(GENE_IN_ONCOKB) %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>% arrange_at(desc(vars(matches("HIGH"))))
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv") %>% filter(GENE_IN_ONCOKB) %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>% arrange_at(vars(matches("HIGH")))
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv") %>% filter(GENE_IN_ONCOKB) %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>% arrange_at(vars(matches("HIGH"))) %>% distinct
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv",col_types=cols(.default="c")) %>% filter(GENE_IN_ONCOKB=="True") %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>% arrange_at(vars(matches("HIGH"))) %>% distinct
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv",col_types=cols(.default="c")) %>% filter(GENE_IN_ONCOKB=="True") %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH"),GENE_IN_ONCOKB) %>% arrange_at(vars(matches("HIGH"))) %>% distinct
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv",col_types=cols(.default="c")) %>% filter(GENE_IN_ONCOKB=="True") %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>% arrange_at(vars(matches("HIGH"))) %>% distinct
read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv",col_types=cols(.default="c")) %>% filter(GENE_IN_ONCOKB=="True") %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>% arrange_at(vars(matches("HIGH"))) %>% distinct %>% mutate(Fusion=gsub("-","::",Fusion))
oncokb=read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv",col_types=cols(.default="c")) %>% filter(GENE_IN_ONCOKB=="True") %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>% arrange_at(vars(matches("HIGH"))) %>% distinct %>% mutate(Fusion=gsub("-","::",Fusion))
oncokb=read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv",col_types=cols(.default="c")) %>% filter(GENE_IN_ONCOKB=="True") %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>% arrange_at(vars(matches("HIGH"))) %>% distinct %>% mutate(Fusion=gsub("-","::",Fusion))
    oncokb=read_tsv(cc(projNo,"UniqueFusions.oncokb.tsv"),col_types=cols(.default="c")) %>%
        separate(Tumor_Sample_Barcode,c("sample","FID"),sep=",") %>%
        separate(Fusion,c("reann_gene5_symbol","reann_gene3_symbol"),sep="-")
oncokb
oncokb=read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv",col_types=cols(.default="c")) %>% filter(GENE_IN_ONCOKB=="True") %>% select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>% arrange_at(vars(matches("HIGH"))) %>% distinct %>% mutate(Fusion=gsub("-","::",Fusion))
    oncokb=read_tsv("Proj_14879_B_UniqueFusions.oncokb.tsv",col_types=cols(.default="c")) %>%
        filter(GENE_IN_ONCOKB=="True") %>%
        select(Fusion,MUTATION_EFFECT,ONCOGENIC,matches("HIGH")) %>%
        arrange_at(vars(matches("HIGH"))) %>%
        distinct %>%
        mutate(Fusion=gsub("-","::",Fusion))
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% filter(nCallers>1) %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(NSamples>1)
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% filter(nCallers>1) %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(NSamples>1) %>% left_join(oncokb)
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(NSamples>1) %>% left_join(oncokb)
cffT %>% filter(!(FusionTag %in% pon_Breakpoints$FusionTag)) %>% arrange(desc(nCallers)) %>% distinct(Fusion,sample,.keep_all=T) %>% group_by(Fusion) %>% eventSummary() %>% arrange(desc(NSamples)) %>% filter(NSamples>1) %>% left_join(oncokb) %>% filter(Fusion %in% nFusions)
nFusions
history("H.R")
savehistory("H.R")
