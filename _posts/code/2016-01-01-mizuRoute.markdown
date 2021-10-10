---
layout: product
title: mizuRoute
name: mizuRoute
date: 2016-01-01 # don't change - this is used for sorting only
author: Naoki Mizukami
categories:
- group_models
img: mizuRouteSchematic.jpg
description: A network-based river routing model for Earth System modelling applications
availability:
- icon: github 
  url: "https://github.com/NCAR/mizuRoute"
documentation: "https://mizuroute.readthedocs.io/en/master/"
collaborators:
- name: Naoki Mizukami
  institution: National Center for Atmospheric Research
  status: active
- name: Martyn Clark
  institution: University of Saskatchewan
  status: active
- name: Shervan Gharari
  institution: University of Saskatchewan
  status: active
- name: Andy Wood
  institution: National Center for Atmospheric Research
  status: active
- name: Erik Kluzek
  institution: National Center for Atmospheric Research
  status: active
---

#### Description

mizuRoute is a large-domain network-based river routing model (_mizu_ means water in Japanese) that is used to simulate spatially distributed streamflow along the river network. mizuRoute can be run in stand-alone mode to post-process large-domain hydrological model simulations for water resource applications, such as streamflow forecasting and evaluating the impacts of climate change on streamflow. mizuRoute is also coupled within the Community Earth System Model to simulate the terrestrial component of the hydrological cycle. mizuRoute has been parallelized using a hierarchal spatial decomposition of the river network. Work is ongoing to include lakes and reservoirs in mizuRoute.

One of the key issues for large-scale river routing, besides the choice of the routing scheme, is the degree of abstracion in the representation of the river network. A vector-based representation of the river network refers to a collection of hydrologic response units (HRUs or spatially discretized areas defined in the model) that are delineated based on topography or catchment boundary. River segments in the vector-based river network, represented by lines, meander through HRUs and connect upstream with downstream HRUs. On the other hand, in the grid-based river network, the HRU is defined by a grid box and river segments connect neighboring grid boxes based on the flow directions. Vector-based river networks are better than coarser resolution (e.g., >1 km) gridded river networks at preserving fine-scale features of the river system such as tortuosity and drainage area, therefore representing more accurate sub-catchment areas and river segment lengths.

#### Publications

Mizukami Naoki, Clark M.P., Sampson Kevin, Nijssen Bart, Mao Yixin, McMillan Hilary, Viger Roland J., Markstrom Steve L., Hay Lauren E., Woods Ross, Arnold Jeffrey R., Brekke Levi D., 2016: mizuRoute version 1: a river network routing tool for continental domain water resources applications. _Geoscientific Model Development_, [doi: 10.5194/gmd-9-2223-2016](http://doi.org/10.5194/gmd-9-2223-2016)

Mizukami Naoki, Clark Martyn P., Gharari Shervan, Kluzek Erik, Pan Ming, Lin Peirong, Beck Hylke E., Yamazaki Dai, 2021: A Vector‐Based River Routing Model for Earth System Models: Parallelization and Global Applications. _Journal of Advances in Modeling Earth Systems_, [doi: 10.1029/2020MS002434](http://doi.org/10.1029/2020MS002434)
