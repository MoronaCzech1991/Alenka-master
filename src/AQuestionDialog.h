#pragma once

#include <qgridlayout.h>
#include <QLabel>
#include <QMessageBox>
#include <QDialog>
#include <QCheckBox>
#include "AButton.h"

class AQuestionDialog  : public QDialog {

    Q_OBJECT

public:
	AQuestionDialog();
    bool MaintainMontage;
	bool TrackManager;
    bool EventTypeManager;
    // bool MontagerManager;
    // bool FilterManager;

private:
	// Layout
	QGridLayout* MainLayout;
	// labels
    QLabel* Message;
	QLabel* TrackManagerLabel;
    QLabel* EventTypeManagerLabel;
    // QLabel* MontageManagerLabel;
    // QLabel* FilterManagerLabel;
	// QLabel* VideoPlayerLabel;

	// Checkbox
	QCheckBox* TrackManagerCheck;
    QCheckBox* EventTypeManagerCheck;
    // QCheckBox* MontageManagerCheck;
    // QCheckBox* FilterManagerCheck;
	// QCheckBox* VideoPlayerCheck;

	// Button
	AButton* ConfirmButton;
	AButton* CancelButton;

private slots:
	void ClickedConfirm(bool checked);
	void ClickedCancel(bool checked);

};
