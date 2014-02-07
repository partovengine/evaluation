# Evaluation Scenarios Guide

* ES1: having two virtual nodes connected with one virtual link (1 figure)
  - ES1.1: draw box plot and cdf for delay and jitter (latency is set to 1 ms)
* ES2: now test for simulation scalability (12 figures)
  - ES2.1: constant number of servers, increasing transmission rate (biggest map)
    + ES2.1.1: with 1ms latency
      * measure average delay,
      * average jitter,
      * average CPU utilization percentage,
      * maximum memory utilization (MRSS)
  - ES2.2: in respect to traffic (biggest map with different number of servers)
    + similar to ES2.1 but instead of increasing rate of one server, rate is kept constant while more and more servers are activated.
    + ES2.2.1: with 1ms latency
      * measure average delay,
      * average jitter,
      * average CPU utilization percentage,
      * maximum memory utilization (MRSS)
  - ES2.3: similar to ES2.2 but with compact-time scheduler instead of real-time scheduler
    + ES2.3.1: with 1ms latency
      * measure average delay,
      * average jitter,
      * wall-clock time
      * maximum memory utilization (MRSS)
* ES3: now test for emulation accuracy (6 figures)
  - ES3.1: having one virtual node connected to eth0 (directly)
    + compare it with one hping3 process and one ns3 emulated node
      * draw box plot and cdf for delay and jitter
  - ES3.2: now test for scalability
    + Else of this scenario and ES2.3.1 (compact-time scenario), in all other cases, simulation should be auto terminated after 60 seconds. In this scenario, we terminate it manually.
    + having a lot of instances of the emulation map, compare with a lot of hping3 processes, and a lot of ns3 emulation maps
      * measure loss percentage,
      * average delay,
      * average jitter,
      * average CPU utilization percentage
      * maximum memory utilization (MRSS)

