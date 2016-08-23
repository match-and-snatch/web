**NOTE:**

> This note and all the following _italicized_ text is informational and should be deleted. Additionally, the items
> non-relevant to the subject of the pull request should be deleted as well. E.g. if task  **Review** checklist items
> does not apply, or if "Screenshots" can't be provided, the  corresponding checklist items ("Screenshots provided…" and
> "Screen recording…") and their related sections should be removed.
>
> Fill **TODO** checklist with all the requirements of the ticket. These are the things you will be working on. You
> should check them as you make progress with the ticket, so other team members and code reviewers know what to look for
> in the code.
>
> When choosing the pull request name, make sure to properly tag it with the **Story number**,
> e.g. `[124018391] Update Rails`.
>
> Make sure the ticket link is correct, i.e. replace **NNNN** with the actual ticket number.
>
> Add `WIP` label if you're still working on the ticket.
>
> PRs should be merged if and only if all pre-merge requirements are satisfied! Pay special attention to them!
>
> Don't delete the review and pre-merge checklists when filing PRs!!!
---

Pivotal [NNNNNNNNN](https://www.pivotaltracker.com/story/show/NNNNNNNNN)

### Description

_Describe the changes and motivations for the pull request, unless obvious from the title._

### TODO

- [ ] _Change the price table_
- [ ] _Update ToS_
- [ ] _Change billing period_

### Review

- [ ] Document public APIs in [YARD](http://yardoc.org/) format.
- [ ] Verify that all classes affected by the changes have **good** top-level documentation.
- [ ] Verify that the legacy code has been updated.
- [ ] Verify that new code has been covered with specs.
- [ ] Test manually and check the provided screenshots.
- [ ] Perform internal demo.
- [ ] Perform or record demo for stakeholders.
- [ ] Get approval from Sergei.
- [ ] Get two :+1: from code review.

### Pre-merge checklist

- [ ] The PR relates to a single subject with a clear title and description in grammatically correct, complete sentences.
- [ ] Verify that feature branch is up-to-date with `master` (if not - rebase it).
- [ ] Verify that new code doesn't generate RuboCop/Linter offenses.
- [ ] Double check the quality of [commit messages](http://chris.beams.io/posts/git-commit/).
- [ ] Squash related commits together.

### Screenshots

| Before                                        | After                                         |
| --------------------------------------------- | --------------------------------------------- |
| _Insert screenshots and/or screen recordings_ | _Insert screenshots and/or screen recordings_ |

### Other

_Provide additional notes, remarks, links, mention specific people to review,…_
