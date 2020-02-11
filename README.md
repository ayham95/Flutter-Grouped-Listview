# Flutter Grouped Listview

A Flutter [listview](https://api.flutter.dev/flutter/widgets/ListView-class.html) on steroids that contains a number of features, one 
of which allows the grouping of data.

## Features
#### Group items
Group items based on a grouping function, as follows:

> ` group: (item) => item[0],` //Here i'm grouping based on first
> letter.

#### Filter items
You can filter the items based on a search query and a search term.

#### Scroll to a desired group
This is self explanatory.

## Example
```dart
GroupedListView(
              group: (item) => item[0],
              items: contacts,
              itemBuilder: (context, item, group) {
                return Card(
                  child: Text(item),
                  margin: EdgeInsets.all(4),
                );
              },
              groupHeaderBuilder: (context, val) {
                return Container(
                  padding: EdgeInsets.all(8),
                  child: Text(val, style: TextStyle(fontSize: 18),),
                  color: Colors.grey[200],
                );
              },
              scrollToSection: scrollToSection,
              search: query,
              searchableTerm: (item) => item,
            ),
``` 

## Thought process
#### Rendering the items
1. sort the items.
2. Iterate the items to calculate how many groups are there to determine
   the list size
   > if the items.length is 10 and i counted 4 groups then the list size
   > is 14.

This method in theory have the same cost of the listView builder of O(n).

I used a Map to save the groups since it has an constant access time.

` if (!map.contains(group)) then ++numberOfGroups & map.add(group) & return groupWidget`

`else return itemWidget[index - numberOfGroups]`

> Note that the code is not syntactically correct.

#### Auto Scrolling
Simply calculate the heights of groups and items, save them in a map and
make the controller scrolls to the desired group on demand.

I also rebuilt the widget by changing it's key when the scrolling is
from bottom to top. And this is also efficient, because the builder only
renders what's visible on the screen.


## Notes

You can run 

>`$ dartdoc`

to generate a web documentation for the grouped_list_view because the
documentation is *dartdoc* ready.
