## 获取数据
rm(list = ls())  ## 魔幻操作，一键清空~
options(stringsAsFactors = F)
library(survminer)
library(GEOquery)
library(ggplot2)
library(clusterProfiler)
library(org.Hs.eg.db)
library(KEGG.db)
library(echarts4r)
library(echarts4r.assets)

surGenes=read.table('dev/genelist.txt')[,1]#change dataframe to vector
head(surGenes)
dd <- AnnoProbe::annoGene(surGenes,ID_type = "SYMBOL")

df <- bitr(unique(surGenes), fromType = "SYMBOL",
           toType = c( "ENTREZID" ),
           OrgDb = org.Hs.eg.db)
head(df)
# entrezid are a series of numbers that fit into enrichGo,enrichKEGG:367
# https://biit.cs.ut.ee/gprofiler/convert
gene_up=df$ENTREZID



# analyse
enrichKK <- enrichKEGG(gene         =  gene_up,
                       organism     = 'hsa',
                       #universe     = gene_all,
                       pvalueCutoff = 0.1,
                       qvalueCutoff =0.1,
                       use_internal_data =T)

# get data frame
tmp=enrichKK@result

# list to df
list2df <- function(inputList) {
  # ldf <- lapply(1:length(inputList), function(i) {
  ldf <- lapply(seq_len(length(inputList)), function(i) {
    data.frame(categoryID=rep(names(inputList[i]),
                              length(inputList[[i]])),
               Gene=inputList[[i]])
  })

  do.call('rbind', ldf)
}

# get gene ID
geneSets <- setNames(strsplit(as.character(tmp$geneID), "/",
                              fixed = TRUE), tmp$Description)
dataf <- list2df(geneSets)

# top 5
tmp <- tmp %>% dplyr::slice_min(pvalue, n = 5)

# kegg and rename cols
nodes1 <- tmp %>%
  dplyr::select(Description, pvalue, Count) %>%
  dplyr::rename(name = Description,value = pvalue,size = Count)

# add group
nodes1$group <- nodes1$name

# gene and add group
nodes2 <- data.frame(
  name = dataf$Gene,
  value = 1,
  size = mean(tmp$Count)/2,
  group = "Genes"
)

# combine
nodes <- rbind(nodes1,nodes2)
row.names(nodes) <- NULL
nodes$size <- as.integer(nodes$size)
nodes$size <- as.numeric(nodes$size)*2
table_dup=nodes[!duplicated(nodes[,1]),]
edges <- dataf %>%
  dplyr::rename(source = categoryID, target = Gene)

# 将svg读取为icons供ea_icons函数调用
dir <- "/Users/yonghe/Downloads/myicons/"
fls <- list.files(dir)
fls <- paste0(dir, fls)
read_icon <- function(x){

  icn <- xml2::read_html(x)

  icn %>%
    rvest::html_node("path") %>%
    rvest::html_attr("d") %>%
    gsub('\\"', "", .)

}

svgs <- lapply(fls, read_icon)
svgs <- unlist(svgs)

name_icon <- function(x){
  x <- gsub("/Users/yonghe/Downloads/myicons/", "", x)
  x <- gsub("\\.svg", "", x)
  x <- gsub(" ", "_", x)
  tolower(x)
}

icons <- tibble::tibble(
  path = svgs,
  name = name_icon(fls)
)

symbol = sample(ea_icons("path"), 22, replace = TRUE)
symbol <- c(rep(ea_icons("evil"),5),rep(ea_icons("geneoutline"),17))

table_dup$symbol <- symbol

e_charts(renderer = "svg") %>%
  e_graph(
    layout = "circular",
    name = TRUE,
    rm_x = TRUE,
    rm_y = TRUE,
    roam = TRUE,
    draggable = TRUE,
    nodeScaleRatio = 0.6,
    layoutAnimation = TRUE,
    circular = list( rotateLabel=TRUE),
    itemStyle = list(opacity = 0.8),
    lineStyle = list(color = 'source',curveness = 0.3),
    label = list(show = TRUE,
                 position= 'right',
                 formatter= '{b}')
  ) %>%
  e_graph_nodes(table_dup, name, value, size, group) %>%
  e_graph_edges(edges, source, target) %>%
  #e_modularity() %>%
  e_tooltip() %>%
  e_toolbox_feature(feature = c("saveAsImage","dataZoom","dataView"))

e_charts(renderer = "svg") %>%
  e_graph(
    layout = "force",
    name = TRUE,
    rm_x = TRUE,
    rm_y = TRUE,
    roam = TRUE,
    draggable = TRUE,
    nodeScaleRatio = 0.6,
    layoutAnimation = TRUE,
    animationDuration=1500,
    edgeSymbol=c('', 'arrow'),
    edgeSymbolSize = 5,
    animationEasingUpdate='cubicOut',
    animationEasing = 'cubicOut',
    categories = 'webkitDep.categories',
    force = list(edgeLength=5, repulsion = 300, gravity = 0.6,
                 layoutAnimation = TRUE,edgeLength =250,initLayout=T),
    circular = list( rotateLabel=TRUE),
    #itemStyle = list(opacity = 0.8),
    lineStyle = list(color = 'source',curveness = 0.1,width=1),
    emphasis = list(focus="adjacency",lineStyle = list(width = 2)),

    label = list(show = TRUE,
                 position= 'right',
                 formatter= '{b}')
  ) %>%
  e_graph_nodes(nodes = table_dup, names = name, value = value, size = size,category = group,symbol) %>%
  e_graph_edges(edges, source, target) %>%
  #e_modularity() %>%
  e_tooltip() %>%
  e_toolbox_feature(feature = c("saveAsImage","dataZoom","dataView")) %>%
  e_color(
    c('#fbb4ae','#b3cde3','#ccebc5','#decbe4','#fed9a6')
  )

# e_charts() %>%
#   e_graph_gl(
#   ) %>%
#   e_graph_nodes(nodes = table_dup, names = name, value = value, size = size, category = group) %>%
#   e_graph_edges(edges, source, target) %>%
#   #e_modularity() %>%
#   e_tooltip()
