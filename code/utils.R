#########################################################################################
### Functions
#########################################################################################

# Get dataframe with emotion scores
get_df_emotions <- function(time_period = "1 ") {
  df_emotions <- parleys %>%
    filter(!is.na(emotions_pos)) %>%
    mutate(datetime_hour = format(floor_date(strptime(createdAtformatted, "%Y-%m-%d %H:%M:%S"), unit = paste0(time_period, "hours")), format = "%H:%M"),
           hour = hour(createdAtformatted))
  df_emotions
}

# plot heatmaps
plot_heat_map <- function(df, selected) {
  df_plot <- df %>%
    group_by(datetime_hour, usergroup, usergroup2) %>%
    summarize(emotion_ave = mean(get(selected)), datetime = min(createdAtformatted)) %>%
    mutate(datetime_hour = paste0("2021-01-06 ", datetime_hour)) %>%
    mutate(datetime_hour = as.POSIXct(strptime(datetime_hour, format = "%Y-%m-%d %H:%M", tz = "UTC"))) %>%
    mutate(datetime_hour = datetime_hour + hours(1))

  df_plot$usergroup2 <- factor(df_plot$usergroup2, levels = c("Other usergroups", "Known rioters"))
  df_plot$usergroup <- factor(df_plot$usergroup, levels=c("Known rioters", "QAnon supporters", "Trump supporters", "Alleged election fraud", "Parler network"))
  
  plot <- ggplot(df_plot, aes(x = as.POSIXct(strptime(datetime_hour, format = "%Y-%m-%d %H:%M", tz = "UTC")), y = usergroup, fill = emotion_ave)) +
    geom_tile() +
    geom_vline(data = timeline %>% slice(1:7), aes(xintercept = as.POSIXct(strptime(Time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC"))), linetype = "dashed", size = 1)
  
  timeline <- timeline %>%
    mutate(usergroup2 = "Other usergroups")
  timeline$usergroup2 <- factor(timeline$usergroup2, levels = c("Other usergroups", "Known rioters"))
  
  if (selected == "sentiment") {
    plot <- plot +
      scale_fill_viridis_c(option = "magma", rescaler = function(x, to = c(0, 1), from = NULL) {
        ifelse(x > -0.25,
               scales::rescale(x,
                               to = to,
                               from = c(-0.25, max(x, na.rm = TRUE))), 0) }) }
  else {
    plot <- plot +
      scale_fill_viridis_c(option = "magma", direction = -1, rescaler = function(x, to = c(0, 1), from = NULL) {
        ifelse(x < 0.4,
               scales::rescale(x,
                               to = to,
                               from = c(min(x, na.rm = TRUE), 0.4)), 1) }) }
  plot <- plot +
    geom_label(data = timeline %>% slice(1:7), aes(x = as.POSIXct(strptime(Time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")), label = Action, y = Inf), size = 50 / .pt, vjust = "outward", colour = "white", fill = "black", inherit.aes = FALSE) +
    scale_x_datetime(breaks = "4 hour",
                     labels = date_format("%H:%M")) +
    ggforce::facet_col(vars(usergroup2), scales = "free_y", space = "free") +
    theme_tufte(base_family = "Helvetica") +
    theme(plot.margin = unit(c(3, 3, 3, 3), "lines"),
          plot.title = element_blank(),
          axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 50),
          axis.text.y = element_text(size = 50),
          legend.position = "bottom",
          legend.title = element_blank(),
          legend.text = element_text(size = 50),
          panel.border = element_blank(),
          strip.text = element_blank()
    ) +
    coord_cartesian(clip = 'off') +   # This keeps the labels from disappearin
    guides(fill = guide_colorbar(barwidth = 40, barheight = 2, title.position = "right", title.hjust = 0.5)) +
    labs(y = NULL, x = NULL)
  plot
}

# plot emotion time series
plot_emotions_ts <- function(df, selected, color = NaN, y_min = 0.05, y_max = 0.4, legend_position = "none") {
  df_plot_ts <- df %>%
    group_by(datetime_hour) %>%
    summarize(emotion_ave = mean(get(selected)), datetime = min(createdAtformatted)) #%>%

  plot_ts <- df_plot_ts %>% ggplot(aes(x = as.POSIXct(strptime(datetime, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")), y = emotion_ave))
  if (!is.na(color)) {
    plot_ts <- plot_ts +
      geom_line(aes(colour = "Sentiment")) +
      scale_colour_manual(name = "", values = c("black"))#, as.character(color)))
  }
  else {
    plot_ts <- plot_ts +
      geom_line(aes(colour = "Sentiment")) +
      scale_colour_manual(name = "", values = c("black"))#, as.character(color)))
    
  }
  
  plot_ts <- plot_ts +
    geom_vline(data = timeline %>% slice(c(1,7)), aes(xintercept = as.POSIXct(strptime(Time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC"))), linetype = "dashed", size = 1) +
    geom_label(data = timeline %>% slice(c(1,7)), aes(x = as.POSIXct(strptime(Time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")), label = Action, y = 0.4), vjust = "outward", size = 25 / .pt, colour = "white", fill = "black") +
    scale_x_datetime(breaks = "1 day",
                     labels = date_format("%Y-%m-%d")) +
    scale_y_continuous(
      expand = c(0, 0),
      limits = c(y_min, y_max),
    ) +
    theme(plot.margin = unit(c(3, 3, 3, 3), "lines"),
          axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 75 / .pt),
          axis.text.y = element_text(hjust = 1, vjust = 1, size = 75 / .pt),
          axis.title.y = element_text(size = 90 / .pt),
          legend.position = legend_position,
          plot.title = element_text(vjust = 3, face = "bold", size = 36)) +
    coord_cartesian(clip = "off") +
    labs(y = str_to_title(selected), x = NULL) +
    ggtitle(str_to_title(selected))
  
  plot_ts
}

# Plot emotions' change
plot_emotions_ts_change <- function(df, selected, color = NA, y_min = -0.05, y_max = 0.04) {
  pct <- function(x) { x - head(x, 1) }
  
  df_plot_ts <- df %>%
    group_by(datetime_hour) %>%
    summarize(emotion_ave = mean(get(selected)), datetime = min(createdAtformatted)) %>%
    mutate(emotion_ave_change = pct(emotion_ave))
  
  plot_ts <- df_plot_ts %>% ggplot(aes(x = as.POSIXct(strptime(datetime, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")), y = emotion_ave_change))
  if (!is.na(color)) {
    plot_ts <- plot_ts +
      geom_line(aes(colour = "Sentiment")) +
      geom_smooth(aes(colour = "Smoothed conditional means"), size = 2) +
      scale_colour_manual(name = "", values = c("black", as.character(color)))
  }
  else {
    plot_ts <- plot_ts +
      geom_line(aes(colour = "Sentiment")) +
      geom_smooth(aes(colour = "Smoothed conditional means"), size = 2) +
      scale_colour_manual(name = "", values = c("black", "blue"))
    
  }
  
  plot_ts <- plot_ts +
    geom_vline(data = timeline %>% slice(1:7), aes(xintercept = as.POSIXct(strptime(Time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC"))), linetype = "dashed", size = 1) +
    geom_label(data = timeline %>% slice(c(1,3,4,7)), aes(x = as.POSIXct(strptime(Time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")), label = Action, y = y_max), vjust = "outward", size = 40 / .pt, colour = "white", fill = "black") +
    scale_x_datetime(breaks = "6 hours",
                     labels = date_format("%H:%M")) +
    scale_y_continuous(
      expand = c(0, 0),
      limits = c(y_min, y_max),
    ) +
    theme(plot.margin = unit(c(3, 3, 3, 3), "lines"),
          legend.position = "none", plot.title = element_text(face = "bold", size = 120 / .pt, vjust = 4), axis.text.x = element_text(size = 120 / .pt, angle = 45, hjust = 1, vjust = 1), axis.title.x = element_text(size = 120 / .pt), axis.text.y = element_text(size = 120 / .pt), axis.title.y = element_text(size = 120 / .pt), legend.text = element_text(size = 120 / .pt)) +
    coord_cartesian(clip = "off") +
    labs(y = paste0("Change of ", str_to_title(selected), " (%)"), x = NULL) +
    ggtitle(str_to_title(selected))
  
  plot_ts
}



## Define user groups
seperate_data_by_user_groups <- function(df_emotions_hashtags, bio, user_group = "Trump") {
  df_emotions <- get_df_emotions()
  
  if (user_group == "Trump") {
    if (!bio) {
      df_emotions <- df_emotions %>% left_join(df_emotions_hashtags %>%
                                                 filter(usergroup == "Trump supporters") %>%
                                                 group_by(id) %>%
                                                 slice(1) %>%
                                                 ungroup(), by = "id") }
    if (bio) {
      df_emotions <- df_emotions %>% left_join(df_emotions_hashtags %>%
                                                 filter(usergroup == "Trump supporters") %>%
                                                 group_by(userid) %>%
                                                 slice(1) %>%
                                                 ungroup(), by = "userid") }
    df_emotions <- df_emotions %>%
      mutate(usergroup = if_else(is.na(usergroup), "Other users", "Trump supporters")) %>%
      mutate(usergroup = factor(usergroup, levels = c("Trump supporters", "Other users")))
  }
  else{
    if (user_group == "Alleged election fraud") {
      if (!bio) {
        df_emotions <- df_emotions %>% left_join(df_emotions_hashtags %>%
                                                   filter(usergroup == "Alleged election fraud") %>%
                                                   group_by(id) %>%
                                                   slice(1) %>%
                                                   ungroup(), by = "id") }
      if (bio) {
        df_emotions <- df_emotions %>% left_join(df_emotions_hashtags %>%
                                                   filter(usergroup == "Alleged election fraud") %>%
                                                   group_by(userid) %>%
                                                   slice(1) %>%
                                                   ungroup(), by = "userid") }
      df_emotions <- df_emotions %>%
        mutate(usergroup = if_else(is.na(usergroup), "Other users", "Alleged election fraud")) %>%
        mutate(usergroup = factor(usergroup, levels = c("Alleged election fraud", "Other users")))
    }
    
    else {
      if (!bio) {
        df_emotions <- df_emotions %>% left_join(df_emotions_hashtags %>%
                                                   filter(usergroup == "QAnon supporters") %>%
                                                   group_by(id) %>%
                                                   slice(1) %>%
                                                   ungroup(), by = "id") }
      if (bio) {
        df_emotions <- df_emotions %>% left_join(df_emotions_hashtags %>%
                                                   filter(usergroup == "QAnon supporters") %>%
                                                   group_by(userid) %>%
                                                   slice(1) %>%
                                                   ungroup(), by = "userid") }
      df_emotions <- df_emotions %>%
        mutate(usergroup = if_else(is.na(usergroup), "Other users", "QAnon supporters")) %>%
        mutate(usergroup = factor(usergroup, levels = c("QAnon supporters", "Other users")))
    }
  }
  df_emotions
}



#########################################################################################
### ggplot2 theme set
#########################################################################################

theme_set(
  theme_bw() +
    theme(legend.position = c(0.7, 0.9),
          legend.title = element_blank(), legend.direction = "horizontal",
          legend.text = element_text(colour = "black", size = 20),
          legend.background = element_rect(fill = "transparent", colour = NA),
          legend.key = element_rect(fill = "transparent", colour = "transparent"),
          legend.key.width = unit(1.25, "cm"), legend.key.height = unit(1.25, "cm")
    ) +
    theme(axis.text.x = element_text(colour = "black", size = 20, vjust = 0.5),
          axis.text.y = element_text(colour = "black", size = 20, vjust = 0.5),
          axis.title.x = element_text(size = 20),
          axis.title.y = element_text(size = 20, vjust = 1.5)
    ) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
)
