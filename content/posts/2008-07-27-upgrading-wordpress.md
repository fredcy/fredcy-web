---
title: upgrading WordPress, or how to turn 30 minutes into several hours
author: fred
#type: post
date: 2008-07-28T03:04:09+00:00
url: /2008/07/27/upgrading-wordpress/
categories:
  - technical

---
It took maybe 30 minutes to upgrade from WordPress 2.2 to 2.6, including time to revisit my notes on how I&#8217;ve done it before and to scan the official install/upgrade notes. But then it took a couple of hours to figure out why categories were gone and how to fix it. Long story short, I had to manually build the wp\_terms table rows based on the old wp\_categories rows. The SQL given in a forum note, [lost categories after 2.6 upgrade][1], did the trick. But what a waste of time.

 [1]: http://wordpress.org/support/topic/191189