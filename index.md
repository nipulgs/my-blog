---
layout: default
title: Home
---

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a> 
      <small>{{ post.date | date: "%b %-d, %Y" }}</small>
    </li>
  {% endfor %}
</ul>
<footer>
  <p text-align: center>
      &copy; {{ site.time | date: "%Y" }} {{ site.owner }}.
      Last updated: {{ site.last_updated }}.
  </p>
</footer>
