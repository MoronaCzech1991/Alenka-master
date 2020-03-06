#pragma once

#ifndef AREALDIALOG_H
#define AREALDIALOG_H

#include <qdialog.h>
#include <qgridlayout.h>

#include "AButton.h"
#include "AComboBox.h"

// Dialog box for InputTimes
class ARealDialog : public QDialog {

public:
	ARealDialog();

private:
	// Components
	QGridLayout* MainLayout;
	AButton* ComfirmButton;
	AButton* CancelButton;
	AComboBox* OpitionTime;
};
#endif
