# Setting up a new GitHub repositopry


## GITHUB_TOKEN

I think this is automatically generated at the start of a GitHub action.


## DOCUMENTER_KEY

One time setup of documentation deployment secret

```
using DocumenterTools

DocumenterTools.genkeys(; user="MarkNahabedian",
                        repo="REPO_NAME")
```

Ignore the Travis nonsense.

The secret key goes in `Settings / Secrets and variables / actions / new repository secret`.
Make sure to give it write permission.  Give it the name `DOCUMENTER_KEY`.

Under `settings / deploy keys / add deploy key` and paste the public key b=value.


## Put in Compat Entries Before CompatHelper Can Carpet Bomb You With PRs

Perhaps by calling

```
NahaJuliaLib.add_compat_entries!("Project.toml")
```

