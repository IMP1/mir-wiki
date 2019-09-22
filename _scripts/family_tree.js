const SVGNS = "http://www.w3.org/2000/svg";

function createFamilyTree(me, parents, siblings, children) {
    let olderSiblings = [];
    let youngerSiblings = [];

    let svg = document.getElementById("family-tree");
    svg.setAttribute("xmlns", SVGNS);
    svg.setAttribute("height", "320px");
    svg.setAttribute("width", "100%");

    let generationLines = document.createElementNS(SVGNS, "g");
    generationLines.setAttributeNS(null, "transform", "translate(0 80)");

    parents.forEach(function(person, i) {
        let x = 120 + i * 120;
        let y = 40;
        drawFamilyMember(svg, person, x, y);
        addLine(generationLines, x + 30, 0, x + 30, 10);
    });
    addLine(generationLines, 150, 10, 270, 10);
    addLine(generationLines, 210, 10, 210, 20);
    addLine(generationLines, 60, 20, 60 + (siblings.length + 1) * 120, 20);
    {
        let thisGenerationIndex = 0;
        youngerSiblings.forEach(function(person, i) {
            let x = 60 + i * 120;
            let y = 160;
            drawFamilyMember(svg, person, x, y);
            thisGenerationIndex = i + 1;
            addLine(generationLines, x + 30, 20, x + 30, 30);
        });
        let meX = 60 + thisGenerationIndex * 120;
        drawFamilyMember(svg, me, meX, 160);
        addLine(generationLines, meX + 30, 20, meX + 30, 30);
        thisGenerationIndex += 1;
        olderSiblings.forEach(function(person, i) {
            let x = 60 + (thisGenerationIndex + i) * 120;
            let y = 160;
            drawFamilyMember(svg, person, x, y);
            addLine(generationLines, x + 30, 20, x + 30, 30);
        });
    }
    svg.appendChild(generationLines);
    // TODO: draw line from me to children
    children.forEach(function(person, i) {
        let x = 120 + i * 120;
        let y = 280;
        drawFamilyMember(svg, person, x, y);
    });
}

function addLine(group, x1, y1, x2, y2) {
    const LINE_STYLE = "stroke:rgb(0,0,0);stroke-width:1";
    let line = document.createElementNS(SVGNS, "line");
    line.setAttribute("x1", x1);
    line.setAttribute("y1", y1);
    line.setAttribute("x2", x2);
    line.setAttribute("y2", y2);
    line.setAttribute("style", LINE_STYLE);
    group.appendChild(line);
}

function drawFamilyMember(svg, person, x, y) {
    let group = document.createElementNS(SVGNS, "g");
    group.setAttributeNS(null, "transform", "translate(" + x + " " + y + ")");

    let name = document.createElementNS(SVGNS, "text");
    name.setAttributeNS(null, "transform", "translate(0 0)");
    name.setAttributeNS(null, "fill", "#000");
    name.textContent = person.name;

    let lifespan = document.createElementNS(SVGNS, "text");
    lifespan.setAttributeNS(null, "transform", "translate(0 24)");
    lifespan.setAttributeNS(null, "fill", "#000");
    lifespan.textContent = yearFromBirthdate(person.birthdate);
    if (person.deathdate) {
        lifespan.textContent += " - " + yearFromBirthdate(person.deathdate);
    }

    group.appendChild(name);        
    group.appendChild(lifespan);
    svg.appendChild(group);    
}

function yearFromBirthdate(birthdate) {
    return "1991";
}