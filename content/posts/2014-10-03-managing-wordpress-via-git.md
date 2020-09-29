---
title: Managing WordPress via git
author: fred
#type: post
date: 2014-10-03T14:31:15+00:00
url: /2014/10/03/managing-wordpress-via-git/
categories:
  - technical

---
I reorganized my self-hosted WordPress system to use git to manage the WordPress code and to move the content outside of the WordPress directory. That way I should be able to do a simple `git pull` and `git checkout $newversion` to update my WordPress. I&#8217;m also keeping my content directory under change management (separately) so that I can update plugins through the web and be able to roll back.

  * `$HOME/blog/wordpress` is a git clone of git@github.com:WordPress/WordPress.git. I make no local changes in this. In particular, all of wp-content is unchanged (I make it unwriteable by Apache to be sure).
  * `$HOME/blog/content` is a copy of the wp-content of my site (prior to moving it outside the wordpress code). It contains the usual: plugins, themes, uploads. It&#8217;s all writeable by Apache so that I can update plugins and themes through the web.
  * `$HOME/blog/wp-config.php` is the usual config file (WordPress looks in the parent directory for it). It&#8217;s standard except for two settings:
    
        define('WP_CONTENT_DIR', '/home/fred/blog/content');  
        define('WP_CONTENT_URL', 'http://fred.yankowski.com/content');
        

  * `/etc/apache2/conf.d/wordpress.conf` defines the VirtualHost for the wordpress site. It has an alias to support special location of the content. (It also has the mod_rewrite rules for permalinks so that I don&#8217;t need an .htaccess file in the wordpress code).
    
        DocumentRoot /home/fred/blog/wordpress
        Alias /content /home/fred/blog/content