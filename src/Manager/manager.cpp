#include "manager.h"
#include "../DataModel/opendatafile.h"
#include "../DataModel/undocommandfactory.h"
#include "../myapplication.h"
#include "sortproxymodel.h"
#include "tablemodel.h"
#include <QtWidgets>
#include <algorithm>
#include <cassert>
#include <sstream>
#include "codeeditdialog.h"
#include <QQuickWidget>

using namespace std;

namespace {

QString replaceTabsAndNewLines(const QString &string) {
  QString newString = string;

  for (auto &e : newString) {
    if (e == '\t' || e == '\n')
      e = ' ';
  }

  return newString;
}

vector<string> splitString(const string &str, char separator = '\n') {
  vector<string> result;
  stringstream stream(str);

  while (stream.good()) {
    string part;
    getline(stream, part, separator);
    result.push_back(part);
  }

  // Ignore last empty row/cell.
  if (result.size() >= 1 && "" == result.back())
    result.pop_back();

  return result;
}

vector<vector<string>> splitLinesToCells(const vector<string> &lines) {
  vector<vector<string>> result;
  result.reserve(lines.size());

  for (const string &e : lines)
    result.push_back(splitString(e, '\t'));

  return result;
}

} // namespace

Manager::Manager(QWidget* parent) : QWidget(parent, Qt::Window) {
    // Construct the table widget.
    tableView = new QTableView(this);
    tableView->setSortingEnabled(true);
    tableView->sortByColumn(0, Qt::AscendingOrder);
    tableView->setSelectionMode(QAbstractItemView::ExtendedSelection);
    tableView->setContextMenuPolicy(Qt::ActionsContextMenu);

    // Add some actions to the tableView.
    auto addRowAction = new QAction("Add Row", this);
    addRowAction->setStatusTip("Add rows at the end");
    connect(addRowAction, SIGNAL(triggered()), this, SLOT(insertRowBack()));
    tableView->addAction(addRowAction);

    auto removeRowsAction = new QAction("Remove Rows", this);
    removeRowsAction->setStatusTip("Remove selected rows");
    removeRowsAction->setShortcut(QKeySequence::Delete);
    removeRowsAction->setShortcutContext(Qt::WidgetWithChildrenShortcut);
    connect(removeRowsAction, SIGNAL(triggered()), this, SLOT(removeRows()));
    tableView->addAction(removeRowsAction);

    auto setColumnAction = new QAction("Set Column", this);
    setColumnAction->setStatusTip("Set all cells in a column to the selected value");
    connect(setColumnAction, SIGNAL(triggered()), this, SLOT(setColumn()));
    tableView->addAction(setColumnAction);

    addSeparator();

    auto copyAction = new QAction("Copy", this);
    copyAction->setStatusTip("Copy as tab separated table");
    copyAction->setShortcut(QKeySequence::Copy);
    copyAction->setShortcutContext(Qt::WidgetWithChildrenShortcut);
    connect(copyAction, SIGNAL(triggered()), this, SLOT(copy()));
    tableView->addAction(copyAction);

    auto copyHtmlAction = new QAction("Copy HTML", this);
    copyHtmlAction->setStatusTip("Copy as a HTML table");
    connect(copyHtmlAction, SIGNAL(triggered()), this, SLOT(copyHtml()));
    tableView->addAction(copyHtmlAction);

    auto pasteAction = new QAction("Paste", this);
    pasteAction->setShortcut(QKeySequence::Paste);
    pasteAction->setShortcutContext(Qt::WidgetWithChildrenShortcut);
    connect(pasteAction, SIGNAL(triggered()), this, SLOT(paste()));
    tableView->addAction(pasteAction);

    addSeparator();

    // Construct buttons.
    auto addRowButton = new QPushButton("Add Row", this);
    connect(addRowButton, SIGNAL(clicked()), this, SLOT(insertRowBack()));

    auto removeRowButton = new QPushButton("Remove Rows", this);
    connect(removeRowButton, SIGNAL(clicked()), this, SLOT(removeRows()));

    // Add the widgets to the layout.
    buttonLayout = new QGridLayout;
    addButton(addRowButton);
    addButton(removeRowButton);

#pragma region Lucas
    // New components add from Lucas 

    //  Add action to change formula matematics 
    auto ChangeMathAction = new QAction("Change Code", this);
    // ChangeMathAction->setStatusTip("Change the math all lines");
    connect(ChangeMathAction, SIGNAL(triggered()), this, SLOT(ChangeMath()));
    tableView->addAction(ChangeMathAction);

    // Add action to change the colorof pens
    auto ChangeColorAction = new QAction("Change Color", this);
    // ChangeColorAction->setStatusTip("Change color of all lines");
    connect(ChangeColorAction, SIGNAL(triggered()), this, SLOT(ChangeColor()));
    tableView->addAction(ChangeColorAction);

    // Add action to change the amplitude of signals
    auto ChangeAmplitudeAction = new QAction("Change Amplitude", this);
    connect(ChangeAmplitudeAction, SIGNAL(triggered()), this, SLOT(ChangeAmplitude()));
    tableView->addAction(ChangeAmplitudeAction);
  
    // Add action to change the Hidden os signals 
    auto ChangeHiddenAction = new QAction("Change Hidden", this);
    connect(ChangeHiddenAction, SIGNAL(triggered()), this, SLOT(ChangeHidden()));
    tableView->addAction(ChangeHiddenAction);

    // Add aciton to change the X 
    auto ChangeXAction = new QAction("Change X", this);
    connect(ChangeXAction, SIGNAL(triggered()), this, SLOT(ChangeX()));
    tableView->addAction(ChangeXAction);

    // Add action to change the Y
    auto ChangeYAction = new QAction("Change Y", this);
    connect(ChangeYAction, SIGNAL(triggered()), this, SLOT(ChangeY()));
    tableView->addAction(ChangeYAction);

    // Add Action to change the Z
    auto ChangeZAction = new QAction("Change Z", this);
    connect(ChangeZAction, SIGNAL(triggered()), this, SLOT(ChangeZ()));
    tableView->addAction(ChangeZAction);

#pragma endregion

  auto box = new QVBoxLayout;
  box->addLayout(buttonLayout);
  box->addWidget(tableView);
  setLayout(box);
}

void Manager::setModel(TableModel *model) {
  QSortFilterProxyModel *proxyModel = new SortProxyModel(model);
  proxyModel->setDynamicSortFilter(false);
  proxyModel->setSourceModel(model);
  tableView->setModel(proxyModel);

  tableView->setItemDelegate(model->getDelegate());

  tableView->sortByColumn(tableView->horizontalHeader()->sortIndicatorSection(),
                          tableView->horizontalHeader()->sortIndicatorOrder());
}

void Manager::addButton(QPushButton *button) {
  int row = buttonsAdded / buttonsPerRow;
  int col = buttonsAdded % buttonsPerRow;

  buttonLayout->addWidget(button, row, col);

  ++buttonsAdded;
}

map<pair<int, int>, QString> Manager::textOfSelection() {
  QModelIndexList indexes = tableView->selectionModel()->selectedIndexes();
  map<pair<int, int>, QString> cells;

  for (const QModelIndex &e : indexes) {
    QVariant value = e.data(Qt::EditRole);

    cells[make_pair(e.row(), e.column())] = value.convert(QMetaType::QString) ? value.toString() : "";
  }

  return cells;
}

void Manager::addSeparator() {
  auto separator = new QAction(this);
  separator->setSeparator(true);
  tableView->addAction(separator);
}

vector<int> Manager::reverseSortedSelectedRows() {
  const auto indexes = tableView->selectionModel()->selection().indexes();
  vector<int> rows;

  for (const auto &e : indexes)
    rows.push_back(e.row());

  sort(rows.begin(), rows.end(), greater<int>());
  return rows;
}

bool Manager::askToDeleteRows(const int rowCount) {
  const QString text =
      QString("You are about to delete %1 row%2. Do you want to continue?")
          .arg(rowCount)
          .arg(rowCount == 1 ? "" : "s");
  const auto buttons =
      QMessageBox::StandardButtons(QMessageBox::Yes | QMessageBox::No);

  return QMessageBox::Yes == QMessageBox::question(this, "Deleting rows", text,
                                                   buttons, QMessageBox::Yes);
}

void Manager::pasteSingleCell(const string &cell) {
  const auto val = QVariant(QString::fromStdString(cell));

  for (auto &i : tableView->selectionModel()->selection().indexes())
    tableView->model()->setData(i, val);
}

void Manager::pasteBlock(const vector<vector<string>> &cells) {
  int startRow, startColumn;
  auto index = tableView->selectionModel()->currentIndex();

  if (index.isValid()) {
    startRow = index.row();
    startColumn = index.column();
  } else {
    startRow = startColumn = 0;
  }

  QAbstractItemModel *model = tableView->model();
  int rowsToInsert =
      startRow + static_cast<int>(cells.size()) - model->rowCount();

  bool insertOK = true;
  for (int i = 0; i < rowsToInsert; ++i)
    insertOK &= insertRowBack();

  if (!insertOK)
    return;

  for (int row = 0; row < static_cast<int>(cells.size()); ++row) {
    for (int col = 0; col < static_cast<int>(cells[row].size()); ++col) {
      if (startColumn + col < model->columnCount()) {
        auto val = QVariant(QString::fromStdString(cells[row][col]));
        model->setData(model->index(startRow + row, startColumn + col), val);
      }
    }
  }
}

void Manager::removeRows() {
  if (!file)
    return;

  const auto rows = reverseSortedSelectedRows();

  if (!rows.empty() && askToDeleteRows(rows.size())) {
    const QString name = metaObject()->className();
    file->undoFactory->beginMacro("remove " + name + " rows");
    
    for (int rowIndex : rows)
      tableView->model()->removeRows(rowIndex, 1);
      
    file->undoFactory->endMacro();
  }
}

void Manager::copy() {
  if (!file)
    return;

  auto cells = textOfSelection();

  QString text;

  auto iter = cells.begin();
  if (iter != cells.end()) {
    text += replaceTabsAndNewLines(iter->second);
  }

  int lastRow = iter->first.first;
  ++iter;
  while (iter != cells.end()) {
    if (iter->first.first != lastRow) {
      lastRow = iter->first.first;

      text += "\n";
    } else {
      text += "\t";
    }

    text += replaceTabsAndNewLines(iter->second);

    ++iter;
  }

  MyApplication::clipboard()->setText(text);
}

void Manager::copyHtml() {
  if (!file)
    return;

  auto cells = textOfSelection();

  QString text;

  text += "<table>";
  text += "<tr>";

  auto iter = cells.begin();
  if (iter != cells.end()) {
    text += "<td>";
    text += iter->second.toHtmlEscaped();
    text += "</td>";
  }

  int lastRow = iter->first.first;
  ++iter;
  while (iter != cells.end()) {
    if (iter->first.first != lastRow) {
      lastRow = iter->first.first;

      text += "</tr><tr>";
    }

    text += "<td>";
    text += iter->second.toHtmlEscaped();
    text += "</td>";

    ++iter;
  }

  text += "</table>";

  MyApplication::clipboard()->setText(text);
}

void Manager::paste() {
  if (!file)
    return;

  const string clipboard = MyApplication::clipboard()->text().toStdString();
  const auto cells = splitLinesToCells(splitString(clipboard));

  if (cells.size() > 0) {
    file->undoFactory->beginMacro("paste");

    if (1 == cells.size() && 1 == cells[0].size())
      pasteSingleCell(cells[0][0]);
    else
      pasteBlock(cells);

    file->undoFactory->endMacro();
  }
}

void Manager::setColumn() {
  if (!file)
    return;

  auto currentIndex = tableView->selectionModel()->currentIndex();

  if (file && currentIndex.isValid()) {
    auto model = tableView->model();
    int col = currentIndex.column();
    auto val = model->index(currentIndex.row(), col).data(Qt::EditRole);
    int rc = model->rowCount();

    file->undoFactory->beginMacro("set column");

    for (int i = 0; i < rc; ++i)
      model->setData(model->index(i, col), val);

    file->undoFactory->endMacro();
  }
}

#pragma region Lucas 

void Manager::ChangeColor()
{
    if (!file)
        return;

    list<ColumnCellView> Cell = GetAllColumnsView();
    QColor color;
    color = QColorDialog::getColor(color);

    if (color.isValid()) 
    {
        foreach (ColumnCellView column , Cell)
        {
             tableView->model()->setData(tableView->model()->index(column.CellLine, 3), color.name());
        }
    }   
}

list<ColumnCellView> Manager::GetAllColumnsView()
{
    QModelIndexList indexes = tableView->selectionModel()->selectedIndexes();
    list<ColumnCellView> Column;

    for (const QModelIndex& e : indexes) {

        QVariant value = e.data(Qt::EditRole);

        ColumnCellView view;
        view.CellColumn = e.column();
        view.CellLine = e.row();
        view.NameCell = value.typeName();
        Column.push_front(view);   
    }

    return Column;

}

void Manager::ChangeMath()
{
    if (!file)
        return;
    list<ColumnCellView> Cell = GetAllColumnsView();
    CodeEditDialog *CodeEditor = new CodeEditDialog(this);
    int result = CodeEditor ->exec();

    if (result == QDialog::Accepted) {

        foreach (ColumnCellView column , Cell)
        {
            tableView->model()->setData(tableView->model()->index(column.CellLine, 2), CodeEditor->getText());
        }
    }
}

void Manager::ChangeAmplitude()
{
    if (!file)
        return;
    list<ColumnCellView> Cell = GetAllColumnsView();

    bool ChangedAmplitude;
    double Amplitude = QInputDialog::getDouble(this, tr("Amplitude changer"),
        tr("Value:"), 0.000001, -100000, 100000, 6, &ChangedAmplitude);

    if (ChangedAmplitude)
    {
        foreach (ColumnCellView column , Cell)
        {
            tableView->model()->setData(tableView->model()->index(column.CellLine, 4), Amplitude);
        }
    }

}

void Manager::ChangeHidden()
{
    if (!file)
        return;
    list<ColumnCellView> Cell = GetAllColumnsView();

    QStringList items;
    items << tr("True") << tr("False");

    bool ChangeHidden;
    bool ValueHidden;
    QString item = QInputDialog::getItem(this, tr("Hidden signals"),
        tr("Value:"), items, 0, false, &ChangeHidden);

    if (ChangeHidden && !item.isEmpty())
    {
        if (item == "True")
            ValueHidden = true;
        else
            ValueHidden = false;

        foreach (ColumnCellView column , Cell)
        {
            tableView->model()->setData(tableView->model()->index(column.CellLine, 5), ValueHidden);
        }
    }
}

void Manager::ChangeX()
{
    if (!file)
        return;
    list<ColumnCellView> Cell = GetAllColumnsView();

    bool ChangedX;
    double XValue = QInputDialog::getDouble(this, tr("Change X value"), tr("Value:"), 1, -100000, 100000, 6, &ChangedX);

    if (ChangedX)
    {
        foreach (ColumnCellView column , Cell)
        {
            tableView->model()->setData(tableView->model()->index(column.CellLine, 6), XValue);
        }
    }

}

void Manager::ChangeY()
{
    if (!file)
        return;
    list<ColumnCellView> Cell = GetAllColumnsView();

    bool ChangedY;
    double YValue = QInputDialog::getDouble(this, tr("Change Y value"), tr("Value:"), 1, -100000, 100000, 6, &ChangedY);

    if (ChangedY)
    {
        foreach (ColumnCellView column , Cell)
        {
            tableView->model()->setData(tableView->model()->index(column.CellLine, 7), YValue);
        }
    }

}

void Manager::ChangeZ()
{
    if (!file)
        return;
    list<ColumnCellView> Cell = GetAllColumnsView();

    bool ChangedZ;
    double ZValue = QInputDialog::getDouble(this, tr("Change Z value"), tr("Value:"), 1, -100000, 100000, 6, &ChangedZ);

    if (ChangedZ)
    {
        foreach (ColumnCellView column , Cell)
        {
            tableView->model()->setData(tableView->model()->index(column.CellLine, 8), ZValue);
        }
    }

}
#pragma endregion 
