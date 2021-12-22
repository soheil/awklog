---
title: "Install AwkLog"
---
This is how you deploy AwkLog on a server:

```shell
curl -sSL https://get.awklog.com | bash
```


The script currently works for Apache and Nginx web servers. It automtically detects the location of the access and errors logs and streams them to your dashboard.

The above command can be run on multiple servers to aggregate all logs and have a central place to see them.
