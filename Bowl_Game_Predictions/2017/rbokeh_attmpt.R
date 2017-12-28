library(rbokeh)


rbPal <- colorRampPalette(c('red','blue'))
t <- sort(tunegrid$acc, index.return=TRUE,decreasing = TRUE)
tunegrid$Col[t$ix] <- rbPal(nrow(tunegrid))

idx <- split(1:27, tunegrid$.min_rows)
names(idx) <- paste0("Min Rows: ", names(idx))

figs <- lapply(idx, function(x) {
  #n <- nrow(tunegrid[x,])
  ## sort by acc
  #t <- sort(tunegrid[x,]$acc, index.return=TRUE)
  #ramp <- colorRampPalette(c("blue", "red"))(n)
  #ramp2 <- ramp[t$ix] 
  
  figure(width = 300, height = 300) %>%
    ly_points(.mtry, .ntree, data = tunegrid[x, ],
              color =Col,legend=FALSE,
              hover = list(.mtry, .ntree,acc)) %>% 
    x_axis(label="# of variables randomly sampled") %>% 
    y_axis(label="# of trees") %>% 
    set_palette(discrete_color = pal_color(ramp))
})



grid_plot(figs,nrow = 2) %>% 
  theme_title(text_color = "blue")





RColorBrewer::brewer.pal(name="Dark2",n=6)
