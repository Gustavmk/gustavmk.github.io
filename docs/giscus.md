

```graphql
query {  
  klinux: repository(owner: "Gustavmk", name: "gustavmk.github.io") {
    id,
    discussionCategory(slug: "blog") {
      id,
      name
    }
  },
}
```
