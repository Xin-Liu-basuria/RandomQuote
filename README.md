# RandomQuote

### WHAT IS THIS

RandomQuote is a plugin for bitbar which can display sentence randomly from the list you added.

if you don't know what is bitbar,please click [here](https://github.com/matryer/bitbar)

### Example 

![default](https://user-images.githubusercontent.com/68738988/101983306-36bc7680-3cb5-11eb-9baa-8531007f2ba6.png)

![⌥ is pressed](https://user-images.githubusercontent.com/68738988/101983326-5e134380-3cb5-11eb-9c2b-240618f90402.png)

![a new random one](https://user-images.githubusercontent.com/68738988/101983352-8ef37880-3cb5-11eb-8b42-d77b969da81f.png)

### Features 

* Basic:display random quote from your list 
* Pin some sentence 
* Allow to display a parallel quote.Pressing ⌥ to see the alternative one.(this is usefull for bilingual quote)
* Send you notification at specific time 
* Be able to adjust the config easily and personize the best display effect
* generate quote list via markdown file which are also suitable for daily use
* convert the quote list to json (default generate the file to downloads folder).

### Installation

1. ```shell
   git clone https://github.com/Xin-Liu-basuria/RandomQuote
   ```

2.  Open RandomQuote.xcodeproj (suppose that you have installed Xcode)

3. Set up your config file and resources file. See the format at Config behind for more info

4. please replace the path of config and resource.md or resource.json  to yours ![here](https://user-images.githubusercontent.com/68738988/101983532-96ffe800-3cb6-11eb-9c66-03e266f0fdef.png)

5. 

   ```shell
   cd RandomQuote
   xcrun -sdk macosx swiftc  main.swift -o RandomQuote.1h.cswift
   ```

6. ```shell
   mv RandomQuote.1h.cswift [your_bitbar_plugin_folder]
   ```

### Config 

#### config file

###### example

``` json
{
    "lengthOfDefaultContent": 50,
    "lengthOfAlternateContent": 30,
    "fontColor": "#C46243",
    "fontSize": 13,
    "fontKind": "Courier",
    "backspaceNumberForwardFrom": 80,
    "markdownIsPrior": true,
    "generateJson": true,
    "pinQuote": [
        1,
        2
    ],
    "notificationHourList": [
        9,
        15,
        21
    ],
    "notificationContent": "Bible Time!"
}
```

those are the config you can set

 #### resources file

1. Json file

   Example:

```  json
[
    {
        "defaultContent": "",
        "alternateContent": "",
        "from": ""
    },
    {
        "defaultContent": "",
        "alternateContent": "",
        "from": ""
    },
    {
        "defaultContent": " ",
        "alternateContent": " ",
        "from": ""
    }
]
```

2. Just markdown file but there are format limitations

   Example in rich text:

   ![in typora](https://user-images.githubusercontent.com/68738988/102077291-02c38b80-3e44-11eb-96ec-ea3c7c3eb326.png)

   **Example in plain text**:

   ![in TextEdit](https://user-images.githubusercontent.com/68738988/102077325-0eaf4d80-3e44-11eb-8371-10bfc84a0a83.png)

   



Every quote consists of "default content","alternative content" and "its resources"

Among those, ONLY "default content" is must.

_Every part should have a **empty line** as interval as you see_

This order can't be changed.

Each part is symbolized by the point list in markdown but Mention: ONLY use "*"

For "alternate content",you should use italic to symbolize it but please use "_" only

For "its resources", you should use bold to symbolize it and also like above

## Encourage 

If you like my product,don't forget to star!😘

## License

RandomQuote is available under the MIT license. See the LICENSE file for more info.