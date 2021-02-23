
library(dplyr)
library(ggplot2)
library(shiny)
library(tidyr)


shinyServer(function(input, output) {
    
    output$plot <- renderPlot({
        
        data <- read.csv("all_r_values.csv") %>%
            filter(window %in% input$window) %>%
            filter(invasive %in% input$strain) 
        
        r1 <- range(data$position)[1]
        r2 <- range(data$position)[2]
        
        y_adj <- max(abs(range(data$r_value[data$invasive == "invasive"])))
        n_adj <- max(abs(range(data$r_value[data$invasive == "other"])))
        
        metric_names <- list(
            "5" = "\nwindow = 5\n", 
            "7" = "\nwindow = 7\n",
            "9" = "\nwindow = 9\n"
        )
        
        metric_labeller <- function(variable,value){
            return(metric_names[value])
        }
        
        data %>%
            mutate(invasive = factor(invasive, levels = c("other", "invasive"))) %>%
            mutate(r_val_std = ifelse(invasive == "invasive", r_value/y_adj, r_value/n_adj)) %>%
            mutate(r_val_std = ifelse(r_val_std < input$range[1], NA, r_val_std)) %>%
            mutate(r_val_std = ifelse(r_val_std > input$range[2], NA, r_val_std)) %>%
            rowwise() %>%
            mutate(window = toString(window)) %>%
            ggplot(aes(x = position, y = invasive)) +
            ggtitle("\nComparison of r(Ms,Md) Values by Invasiveness") +
            geom_tile(aes(fill = r_val_std)) +
            scale_x_continuous(name = "\nMSA-polymorphic index\n", breaks = seq(25,100,25), limits = c(5,112)) +
            scale_y_discrete(name = "", labels = c("other", "invasive"),
                             expand = expand_scale(add = 1)) +
            scale_fill_gradientn(name = "standardized\nr(Ms,Md)\n", limits = c(-1, 1), 
                                 colours = c("#FF5865","White","#577CCC"),
                                 na.value = "gray20") +
            facet_wrap(~window, nrow = 3, labeller = metric_labeller) +
            theme_minimal() +
            theme(panel.grid.major.y = element_blank(),
                  panel.grid.minor.x = element_blank(),
                  text = element_text(color = "white", family = "Avenir"), 
                  axis.text = element_text(color = "white", size = 10),
                  axis.title.x = element_text(angle = 0, vjust = .5, hjust = .5, size = 10),
                  plot.title = element_text(family = "Avenir Black", hjust = .5, size = 18), 
                  plot.subtitle = element_text(family = "Avenir", hjust = .5, size = 10),
                  plot.background = element_rect(fill = "black", color = "black"), 
                  legend.background = element_rect(fill = "black"), 
                  legend.key = element_rect(fill = "black"),
                  legend.key.size = unit(.6, "cm"),
                  legend.text = element_text(size = 8),
                  strip.text = element_text(color = "white", family = "Avenir", size = 12))
        
        
    })
    
})
