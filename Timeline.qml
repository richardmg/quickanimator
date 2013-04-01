import QtQuick 2.1
import QtQuick.Controls 1.0

ListView {
    id: view
    model: rows
    clip: true
    delegate: TimeLineDelegate {}
}

