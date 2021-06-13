#' plot cnet of enrichKEGG
#'
#'
#' @title cneteplot
#' @param data result from enrichKEGG
#' @param showCategory number of enriched terms to display(default 5)
#' @param scale size of nodes(default 2)
#' @param layout "force" or "circular"(default force)
#' @param colors a color list(default rainbow(5))
#' @return a echart plot
#' @importFrom grDevices rainbow
#' @export
#' @examples
#' cneteplot(enrichKK)
cneteplot <- function(data, showCategory, scale, layout, colors) {
  showCategory = 5
  scale = 2
  layout = "force"
  colors = rainbow(showCategory)
  dt <- cnetData(data, showCategory = showCategory, scale)
  if (layout == "force") {
    cnet_force(dt,colors)
  } else {
    cnet_circle(dt,colors)
  }
}

#' cnet_force
#'
#' @param x data
#' @param colors color list
#' @importFrom echarts4r e_charts
#' @importFrom echarts4r e_graph
#' @importFrom echarts4r e_graph_nodes
#' @importFrom echarts4r e_graph_edges
#' @importFrom echarts4r e_tooltip
#' @importFrom echarts4r e_toolbox_feature
#' @importFrom echarts4r e_color
#' @return
#' @noRd
cnet_force <- function(x,colors) {
  p <- e_charts(renderer = "svg") %>%
    e_graph(
      layout = "force",
      name = TRUE,
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
    e_graph_nodes(nodes = x@nodes, names = name, value = value, size = size,category = group) %>%
    e_graph_edges(x@edges, source, target) %>%
    #e_modularity() %>%
    e_tooltip() %>%
    e_toolbox_feature(feature = c("saveAsImage","dataZoom","dataView")) %>%
    e_color(
     colors
    ) ## 自定义颜色
  return(p)
}

#' cnet_circle
#'
#' @title
#' @param x data
#' @param colors color list
#' @importFrom echarts4r e_charts
#' @importFrom echarts4r e_graph
#' @importFrom echarts4r e_graph_nodes
#' @importFrom echarts4r e_graph_edges
#' @importFrom echarts4r e_tooltip
#' @importFrom echarts4r e_toolbox_feature
#' @importFrom echarts4r e_color
#' @return
#' @noRd
cnet_circle <- function(x,colors) {
  e_charts(renderer = "svg") %>%  # 渲染器决定下载的时候是png还是svg
    e_graph(
      layout = "circular", # 环形
      name = TRUE,
      roam = TRUE,
      draggable = TRUE, # 可以拖拽吗
      nodeScaleRatio = 0.6, #
      layoutAnimation = TRUE, # 动画
      circular = list( rotateLabel=TRUE), # 标签适应环形旋转
      # itemStyle = list(opacity = 0.8), # 对象的颜色透明度等
      lineStyle = list(color = 'source',curveness = 0.3), # 线的颜色和曲度
      label = list(show = TRUE, #字显示，位置格式
                   position= 'right',
                   formatter= '{b}')
    ) %>%
    e_graph_nodes(x@nodes, name, value, size, group) %>% # 节点
    e_graph_edges(x@edges, source, target) %>% # 连线
    #e_modularity() %>%
    e_tooltip() %>%
    e_toolbox_feature(feature = c("saveAsImage","dataZoom","dataView")) %>% # 右上角的按钮
    e_color(
    colors
  ) ## 自定义颜色
}
