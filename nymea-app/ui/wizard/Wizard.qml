import QtQuick 2.9
import QtQuick.Controls 2.1

StackView {
    id: wizard

    function startWizard(pages) {
        wizard.clear();
        d.queuedPages = pages
        d.advance();
    }

    QtObject {
        id: d
        property var queuedPages: []
        property var passedPages: []

        function advance() {
            if (d.queuedPages.length == 0) {
                print("Wizard complete")
                wizard.clear();
                return
            }

            print("Wizard: Advancing. Remaining pages:", d.queuedPages)

            var pageName = d.queuedPages.shift();
            d.passedPages.push(pageName)

            var page;
            if (typeof(pageName) == "string") {
                page = wizard.push("pages/" + pageName + ".qml")
            } else if (typeof(pageName) == "object") {
                page = wizard.push(pageName)
            }

            page.next.connect(function(next) {
                print("Wizard: next called for", next)
                if (Array.isArray(next)) {
                    next.slice().reverse().forEach(function(item) {d.queuedPages.unshift(item)})
                } else {
                    d.queuedPages.unshift(next)
                }
                advance();
            });
            page.back.connect(function() {
                print("Wizard: back called")
                if (d.passedPages.length == 0) {
                    print("Cannot move before the first page! Exiting wizard.")
                    wizard.clear();
                    return;
                }

                var pageName = d.passedPages.slice(-1)[0]
                d.queuedPages.unshift(pageName);
                print("* popping page")
                wizard.pop();
            })
            page.complete.connect(function(){
                print("Wizard: Page complete")
                advance();
            })
        }
    }
}

