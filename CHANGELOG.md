
## 0.0.2
- Fixed an issue where adding the format to the request context
  destructively altered the rack env, preventing cancan from knowing the
  controller and action.
