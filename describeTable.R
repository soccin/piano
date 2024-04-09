require(tibble)

describe_table<-function(tbl) {
    tibble(
        field=colnames(tbl),
        type=sapply(tbl,class),
        frac.na=apply(tbl,2,\(x){mean(is.na(x))}),
        num.unique=apply(tbl,2,\(x){len(unique(x))}),
        value.1=unlist(tbl[1,]),
        value.rand=unlist(tbl[sample(nrow(tbl),1),]),
        value.N=unlist(tbl[nrow(tbl),])
    )
}
