#ifndef ATIMERDIALOG_H
#define ATIMERDIALOG_H

#include "AButton.h"
#include "AComboBox.h"

#include <qdialog.h>
#include <qgridlayout.h>
#include <qlabel.h>
#include <QCheckBox>

// Dialog box for InputTimes
class ATimerDialog : public QDialog {

    Q_OBJECT

public:
	ATimerDialog();

private:
	// vars

	// Components
	QGridLayout* MainLayout;
	AButton* ConfirmButton;
	AButton* CancelButton;
	QLabel* LbHours;
	QLabel* LbMinutes;
	QLabel* LbSeconds;

	QCheckBox* ChBxHours;
	QCheckBox* ChBxMinutes;
	QCheckBox* ChBxSeconds;

private slots:
	void ClickedCancel(bool checked);

};
#endif
