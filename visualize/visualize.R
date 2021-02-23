
library(dplyr)
library(ggplot2)
library(tidyr)

data <- read.csv("all_r_values.csv") 

r1 <- range(data$position)[1]
r2 <- range(data$position)[2]

y_adj <- max(abs(range(data$r_value[data$invasive == "yes"])))
n_adj <- max(abs(range(data$r_value[data$invasive == "no"])))

# -----
# Main plot:
# -----

cutoff <- -1

metric_names <- list(
    "5" = "\nwindow = 5\n", 
    "7" = "\nwindow = 7\n",
    "9" = "\nwindow = 9\n"
)

metric_labeller <- function(variable,value){
    return(metric_names[value])
}

p1 <- data %>%
    mutate(invasive = factor(invasive, levels = c("no", "yes"))) %>%
    mutate(r_val_std = ifelse(invasive == "yes", r_value/y_adj, r_value/n_adj)) %>%
    mutate(r_val_std = ifelse(r_val_std < cutoff, NA, r_val_std)) %>%
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
          plot.title = element_text(family = "Avenir Black", hjust = .5, size = 14),
          plot.subtitle = element_text(family = "Avenir", hjust = .5, size = 10),
          plot.background = element_rect(fill = "black", color = "black"), 
          legend.background = element_rect(fill = "black"), 
          legend.key = element_rect(fill = "black"),
          legend.key.size = unit(.6, "cm"),
          legend.text = element_text(size = 8),
          strip.text = element_text(color = "white", family = "Avenir", size = 12))

p1


# -----
# Epitope plot:
# -----

cutoff <- .7

metric_names <- list(
    "5" = "window = 5\n", 
    "7" = "window = 7\n",
    "9" = "window = 9\n"
)

metric_labeller <- function(variable,value){
    return(metric_names[value])
}

p2 <- data %>%
    mutate(invasive = factor(invasive, levels = c("no", "yes"))) %>%
    mutate(r_val_std = ifelse(invasive == "yes", r_value/y_adj, r_value/n_adj)) %>%
    mutate(r_val_std = ifelse(r_val_std < cutoff, NA, r_val_std)) %>%
    rowwise() %>%
    mutate(window = toString(window)) %>%
    ggplot(aes(x = position, y = invasive)) +
    ggtitle("\nValidation Against Epitopes Identified by Pulzova et al.",
            subtitle = "only showing positions with standardized r(Ms,Md) > .7\n") +
    geom_tile(aes(fill = r_val_std)) +
    # E3 box
    geom_vline(xintercept = 6.5, color = "white") +
    geom_vline(xintercept = 10.5, color = "white") +
    geom_segment(x = 6.5, xend = 10.5, y = 0.1, yend = 0.1, color = "white") +
    geom_segment(x = 6.5, xend = 10.5, y = 2.9, yend = 2.9, color = "white") +
    # E5 box
    geom_vline(xintercept = 100.5, color = "white") +
    geom_vline(xintercept = 109.5, color = "white") +
    geom_segment(x = 100.5, xend = 109.5, y = 0.1, yend = 0.1, color = "white") +
    geom_segment(x = 100.5, xend = 109.5, y = 2.9, yend = 2.9, color = "white") +
    #
    scale_x_continuous(name = "\n\n\n", breaks = c(8.5, 105), labels = c("E3", "E5"), limits = c(5,112)) +
    scale_y_discrete(name = "", labels = c("other", "invasive"),
                     expand = expand_scale(add = 1)) +
    scale_fill_gradientn(name = "standardized\nr(Ms,Md)\n", limits = c(-1, 1), 
                         colours = c("#FF5865","White","#577CCC"),
                         na.value = "gray20") +
    facet_wrap(~window, nrow = 3, labeller = metric_labeller, scales = "free") +
    theme_minimal() +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor.x = element_blank(),
          text = element_text(color = "white", family = "Avenir"), 
          axis.text = element_text(color = "white", size = 10),
          axis.title.x = element_text(angle = 0, vjust = .5, hjust = .5, size = 10),
          plot.title = element_text(family = "Avenir Black", hjust = .5, size = 14), 
          plot.subtitle = element_text(family = "Avenir", hjust = .5, size = 10),
          plot.background = element_rect(fill = "black", color = "black"), 
          legend.background = element_rect(fill = "black"), 
          legend.key = element_rect(fill = "black"),
          legend.key.size = unit(.6, "cm"),
          legend.text = element_text(size = 8),
          strip.text = element_text(color = "white", family = "Avenir", size = 12))

p2


















