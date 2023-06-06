library(tidyverse)
library(sf) #for spatial manipulation
library(mapview) #for interactive visualization of the spatial data
library(parallel)
library(ggplot2)
library(png)
library(transformr)
library(gganimate)

tracking <- read.csv("/home/ceci/data/foraging/csv/merged.csv") %>% 
  mutate(season = tolower(season))

coords <- read.csv("/home/ceci/data/foraging/island.csv") %>%
  separate(A, into = c("A_x", "A_y"), sep = ";") %>% 
  separate(B, into = c("B_x", "B_y"), sep = ";") %>% 
  separate(C, into = c("C_x", "C_y"), sep = ";") %>% 
  separate(D, into = c("D_x", "D_y"), sep = ";") %>% 
  separate(door, into = c("door_x", "door_y"), sep = ";") %>% 
  mutate(unique_trial_ID = paste(season, trial, ID, sep = "_"))

coords$A_x <- as.numeric(coords$A_x) * 0.187192
coords$A_y <- as.numeric(coords$A_y) * 0.187192
coords$B_x <- as.numeric(coords$B_x) * 0.187192
coords$B_y <- as.numeric(coords$B_y) * 0.187192
coords$C_x <- as.numeric(coords$C_x) * 0.187192
coords$C_y <- as.numeric(coords$C_y) * 0.187192
coords$D_x <- as.numeric(coords$D_x) * 0.187192
coords$D_y <- as.numeric(coords$D_y) * 0.187192
coords$door_x <- as.numeric(coords$door_x) * 0.187192
coords$door_y <- as.numeric(coords$door_y) * 0.187192


tracking[c('ANGLE')][sapply(tracking[c('ANGLE')], is.infinite)] <- NA #transform inf values in NA, then drop them
tracking <- tracking %>% 
  drop_na(ANGLE) %>% 
  mutate(unique_trial_ID = paste(season, trial, ID, sep = "_"))

track_ls <- split(tracking, tracking$unique_trial_ID)

all_ls <- lapply(track_ls, function(x){
  #to call all blocks one at a time
  #x = track_ls[[5]] #can change to 2,3 or 4
  
  #extract food coordinates for this trial AND convert to a sf object
  door <- coords %>%
    filter(unique_trial_ID == unique(x$unique_trial_ID)) %>%
    dplyr::select(c("door_x", "door_y")) %>%
    st_as_sf(coords = c("door_x", "door_y"))
  door_buffer <- door %>%
    st_buffer(dist = 4)
  
  islands <- c("A", "B", "C", "D")
  hex_ls <- list()
  islands_buffer <- list()
  for (island in islands) {
    filtered_coords <- coords %>%
      filter(unique_trial_ID == unique(x$unique_trial_ID)) %>%
      dplyr::select(paste0(island, "_x"), paste0(island, "_y")) %>%
      mutate(!!paste0(island, "_x") := as.numeric(!!sym(paste0(island, "_x"))),
        !!paste0(island, "_y") := as.numeric(!!sym(paste0(island, "_y"))))
    center <- as.numeric(filtered_coords[1, ])
    distance <- 9
    hex_coords <- matrix(nrow = 6, ncol = 2)
    for (i in 1:6) {
      angle <- (i - 1) * 2 * pi / 6
      hex_coords[i, ] <- center + distance * c(cos(angle), sin(angle))
    }
    hex_closed <- rbind(hex_coords, hex_coords[1, ])
    hex_sf <- st_polygon(list(hex_closed))
    hex_ls[[island]] <- hex_sf
    island_buffer <- hex_sf %>%
      st_buffer(dist = 4)
    islands_buffer[[island]] <- island_buffer
  }
  
  track_sf <- x %>%
    st_as_sf(coords = c("x", "y"))
  
  intersection_df <- data.frame()
  for (island in islands) {
    at_island <- track_sf %>%
      #st_intersection(hex_ls[[island]]) %>%
      st_intersection(islands_buffer[[island]]) %>% 
      as.data.frame() %>%
      arrange(frame) %>%
      mutate(island = island) %>%
      mutate(timediff = frame - lag(frame)) %>%
      mutate(new_timediff = ifelse(is.na(timediff) | timediff != 1, 1, 0)) %>%
      mutate(visit_seq = cumsum(new_timediff))
    intersection_df <- rbind(intersection_df, at_island)
  }
  track_sf_2 <- track_sf %>%
    full_join(intersection_df[c("frame", "island", "visit_seq")]) %>% 
    arrange(frame) %>% 
    mutate(journey = ifelse(!is.na(island), paste0("at_", island, "_", visit_seq), "travelling"))
  
  track_save <- track_sf_2 %>% 
    extract(geometry, c('x', 'y'), '\\((.*), (.*)\\)', convert = TRUE) %>% 
    relocate(x, .after = frame) %>% 
    relocate(y, .after = x) %>% 
    relocate(unique_trial_ID, .before = ID)
  
  write.csv(track_save, file = paste0("/home/ceci/data/foraging/results/", unique(x$unique_trial_ID),".csv"))
})

result <- read.csv("/home/ceci/data/foraging/results/merged.csv")

\