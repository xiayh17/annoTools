## 获取数据
rm(list = ls())  ## 魔幻操作，一键清空~
options(stringsAsFactors = F)
library(clusterProfiler)
library(org.Hs.eg.db)
# library(KEGG.db)

surGenes = read.table('dev/genelist.txt')[,1]#change dataframe to vector
head(surGenes)
dd <- AnnoProbe::annoGene(surGenes,ID_type = "SYMBOL")

df <- bitr(unique(surGenes), fromType = "SYMBOL",
           toType = c( "ENTREZID" ),
           OrgDb = org.Hs.eg.db)
head(df)
# entrezid are a series of numbers that fit into enrichGo,enrichKEGG:367
# https://biit.cs.ut.ee/gprofiler/convert
gene_up = df$ENTREZID



# analyse
enrichKK <- enrichKEGG(gene         =  gene_up,
                       organism     = 'hsa',
                       #universe     = gene_all,
                       pvalueCutoff = 0.1,
                       qvalueCutoff = 0.1,
                       use_internal_data = T)

# make name readable
enrichKK <- DOSE::setReadable(enrichKK, OrgDb='org.Hs.eg.db',keyType='ENTREZID')

annoTools::cneteplot(enrichKK)

