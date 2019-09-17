function generateArticleContentsList() {
    let article = document.getElementsByTagName("article")[0];
    if (!article) { return; }
    let contentsList = document.getElementById("article-contents-list");
    if (!contentsList) { return; }
    article.getElementsByTagName("section").foreach(function(section) {
        let header = section.getElementsByTagName("h2")[0];
        let listItem = document.createElement("li");
        let title = header.textContent;
        let anchor = titleToAnchor(title);
        let link = document.createElement("a");
        link.href = "#" + anchor;
        header.id = anchor;
        link.textContent = title
        listItem.appendChild(link);
        contentsList.appendChild(listItem);
    });
}

function titleToAnchor(title) {
    return title.replace(/\s/g, "-")
                .replace(/\'/g, "")
                .toLowerCase();
}

// TODO: add generateArticleContentsList to document.onload