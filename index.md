---
layout: default
title: Home
---

<h1>{{ site.title }}</h1>
<p>{{ site.description }}</p>

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a> 
      <small>{{ post.date | date: "%b %-d, %Y" }}</small>
      {% if post.tags %}
        <br>Tags:
        {% for tag in post.tags %}
          <a href="{{ '/tags/' | append: tag | relative_url }}">{{ tag }}</a>{% unless forloop.last %}, {% endunless %}
        {% endfor %}
      {% endif %}
    </li>
  {% endfor %}
</ul>
