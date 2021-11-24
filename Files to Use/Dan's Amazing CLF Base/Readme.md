This file is used as a solid base for further customizing with your own entries.

The entries in the filter will not appear inside the GUI filter editor, but will be active when scanning items. You can add and remove your own entries like normal, and they will appear on the GUI list editable. The reason for this, is that this list is using a new format of groups which is very difficult to make a GUI for. SO for now its edited manually if you want more advanced group types.

To modify the filter groups within this list, you will need to do so manually. This includes making changes to the stash tab which the items are sent. To quickly change the tab of the file, find and replace `"StashTab": "11"` with the tab you would rather use.

Take the `LootFilter.json` file and place it within your `Save` folder, if you already have one, make sure to rename it before copying the new file. You can copy your old filter entries and paste them inside the new file. Try doing this change on a JSON compatible editor so that you can see if you have done the merge properly.

When pasting in old file entries, always ensure it starts with a quoted `"keyname"`, and that they end with a comma. Paste the entries into line 2 of the file.

[Here is a link to edit the filter on the cloud](https://jsoneditoronline.org/#left=cloud.c33e0c7b6de047489bcac324f50039dc)