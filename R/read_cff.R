suppressPackageStartupMessages({
    require(dplyr)
    require(readr)
})

read_cff<-function(cfile) {

    read_tsv(cfile,show_col_types = FALSE,progress=F) |>
        mutate(Fusion=paste0(reann_gene5_symbol,"::",reann_gene3_symbol)) |>
        mutate(FusionTag=paste0(gene5_chr,":",gene5_breakpoint,":",gene5_strand,"::",
                                gene3_chr,":",gene3_breakpoint,":",gene3_strand))

}

#'
#' THIS MUST BE RUN ON A SINGLE SAMPLE CFF
#' DOES NOT WORK ON MULTI SAMPLE
#'
#' First get rid of all `NA` and gene names with `-` in them
#' these are likely unannotated anyway
#' If there are multiple fusions from one tool (why?)
#' pick the one with the higest reads counts (split then span)
#'
#' Then create a `Tools` column that is the collapse of the callers
#' along with an `nCallers` column
#'
#' Then remove degenerate or unexplainable columns
#' Remove fields with degenerate values
#' Remove is_inframe becuase it seems not to be set correctly
#' Remove score used for picking annotation but obscure annotation is better
#' Remove Metafusion_flag: hard to explain data in other columns

clean_cff<-function(cff) {

    if(len(unique(cff$sample))>1) {
        cat("\n\n   ERROR Must be run only on a single sample cff file\n\n")
        halt("FATAL::ERROR")
    }

    cff1=cff |>
        filter(!is.na(reann_gene5_symbol)) |>
        filter(!is.na(reann_gene3_symbol)) |>
        filter(!grepl("-",reann_gene5_symbol)) |>
        filter(!grepl("-",reann_gene3_symbol)) |>
        arrange(desc(max_split_cnt),desc(max_span_cnt)) |>
        distinct(FusionTag,tool,.keep_all=T)

    collapseCallers=cff1 |>
        select(FusionTag,tool) |>
        group_by(FusionTag) |>
        summarize(Tools=paste(sort(tool),collapse=","),nCallers=n())

    cff1 |>
        select(-tool) |>
        distinct(FusionTag,.keep_all=T) |>
        left_join(collapseCallers,by="FusionTag") |>
        select(-library,-disease,-dnasupp,-captured_reads) %>%
        select(-is_inframe) |>
        select(-score) |>
        select(-Metafusion_flag) |>
        select(-coding_id_distance,-gene_interval_distance,-cluster) %>%
        select(sample,Fusion,everything())


}

