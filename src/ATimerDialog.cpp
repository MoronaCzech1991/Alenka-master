#include "AButton.h"
#include "ATimerDialog.h"

#include <QToolButton>
#include <QGridLayout>
#include <QLabel>
#include <QSlider>


ATimerDialog::ATimerDialog()
{
    ConfirmButton = new AButton();
    ConfirmButton->setText("Confirm");
   
    CancelButton = new AButton();
    CancelButton->setText("Cancel");

    LbHours = new QLabel();
    LbHours->setText("Hours: ");
    ChBxHours = new QCheckBox();
  
    LbMinutes = new QLabel();
    LbMinutes->setText("Minutes: ");
    ChBxMinutes = new QCheckBox();

    LbSeconds = new QLabel();
    LbSeconds->setText("Seconds: ");
    ChBxSeconds = new QCheckBox();

    // Desing
    MainLayout = new QGridLayout(this);
    // define buttons
    MainLayout->setSizeConstraint(QLayout::SetFixedSize);
    MainLayout->setColumnMinimumWidth(0,100);
    MainLayout->setColumnMinimumWidth(1,100);

    MainLayout->addWidget(LbHours, 1, 0);
    MainLayout->addWidget(ChBxHours, 1, 1);

    MainLayout->addWidget(LbMinutes, 2, 0);
    MainLayout->addWidget(ChBxMinutes,2,1);

    MainLayout->addWidget(LbSeconds, 3, 0);
    MainLayout->addWidget(ChBxSeconds, 3,1);

    MainLayout->addWidget(ConfirmButton, 4, 0, 1, 1, Qt::AlignLeft);
    MainLayout->addWidget(CancelButton, 4, 1, 1, 1, Qt::AlignRight);

    this->setWindowTitle("Timer Config");
    this->setWindowIcon(QIcon(":/icons/time.png"));
    // setGeometry(geometry().x(), geometry().y(), 200, 400);
    this->resize(200, 100);

    // Buttons design
    ConfirmButton->setFixedWidth(60);
    ConfirmButton->setFixedHeight(30);
    ConfirmButton->setStyleSheet("text-align:center;");

    CancelButton->setFixedWidth(60);
    CancelButton->setFixedHeight(30);
    CancelButton->setStyleSheet("text-align:center;");

    // connections 
    connect(CancelButton, SIGNAL(clicked(bool)), this, SLOT(ClickedCancel(bool)));
}

void ATimerDialog::ClickedCancel(bool checked)
{
    this->close();
}





