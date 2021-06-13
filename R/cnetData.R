#' Class cnetdata
#'
#' @slot nodes data.frame.
#' @slot edges data.frame.
#'
#' @return
#' @noRd
setClass(Class="cnetdata",
         representation(
           nodes = "data.frame",
           edges = "data.frame"
         )
)

#' list2df
#'
#' @param inputList a list
#' @return a data frame
#' @noRd
list2df <- function(inputList) {
  ldf <- lapply(seq_len(length(inputList)), function(i) {
    data.frame(categoryID=rep(names(inputList[i]),
                              length(inputList[[i]])),
               Gene=inputList[[i]])
  })
  do.call('rbind', ldf)
}

#' cnetData
#'
#' @param x enrichment result
#' @param showCategory number of enriched terms to display
#' @importFrom methods new
#' @importFrom stats setNames
#' @return data for vis of ECharts
#' @noRd
cnetData <- function(x, showCategory, scale) {

  showCategory <- 5
  scale = 2

  # get data frame
  tmp = x@result

  # top number of enriched terms to display
  top <- tmp %>% dplyr::slice_min(pvalue, n = showCategory)

  # get gene ID
  geneSets <- setNames(strsplit(as.character(top$geneID), "/",
                                fixed = TRUE), top$Description)
  dataf <- list2df(geneSets)

  # kegg and rename cols
  nodes1 <- top %>%
    dplyr::select(Description, pvalue, Count) %>%
    dplyr::rename(name = Description,value = pvalue,size = Count)

  # add group
  nodes1$group <- nodes1$name

  # gene and add group
  nodes2 <- data.frame(
    name = dataf$Gene,
    value = 1,
    size = mean(top$Count)/2,
    group = "Genes"
  )

  # combine
  nodes <- rbind(nodes1,nodes2)
  row.names(nodes) <- NULL
  nodes$size <- as.integer(nodes$size)
  nodes$size <- as.numeric(nodes$size)*scale
  nodes = nodes[!duplicated(nodes[,1]),]
  edges <- dataf %>%
    dplyr::rename(source = categoryID, target = Gene)

  return(new("cnetdata",
             nodes = nodes,
             edges = edges))

}
